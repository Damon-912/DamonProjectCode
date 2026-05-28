import React, { useState, useEffect, useMemo } from 'react';
import {
  Row,
  Col,
  Table,
  Select,
  DatePicker,
  Button,
  Space,
  Typography,
  Tag,
  Spin,
  Progress,
} from 'antd';
import {
  DollarOutlined,
  RiseOutlined,
  FallOutlined,
  WarningOutlined,
  PieChartOutlined,
  BarChartOutlined,
  LineChartOutlined,
  ReloadOutlined,
  ThunderboltOutlined,
  AreaChartOutlined,
  CaretUpOutlined,
  CaretDownOutlined,
} from '@ant-design/icons';
import ReactECharts from 'echarts-for-react';
import type { ColumnsType } from 'antd/es/table';
import type { WarningRecord } from '@/api/warning';
import { queryWarningRecords } from '@/api/warning';
import { useDict } from '../../hooks/useDict';
import { getDictLabel } from '../../utils/dict';
import dayjs from 'dayjs';
import zhCN from 'antd/es/date-picker/locale/zh_CN';

const { Text } = Typography;
const { RangePicker } = DatePicker;

/* ======================== 常量 ======================== */
const WARNING_TYPE_COLORS: Record<string, string> = {
  '费用超支': '#ef4444', '低倍率': '#f59e0b', '高倍率': '#dc2626',
  '编码异常': '#8b5cf6', '分解住院': '#3b82f6', '费用过低': '#10b981',
};
const WARNING_LEVEL_COLORS: Record<string, string> = {
  '1': '#22c55e',
  '2': '#f59e0b',
  '3': '#ef4444',
};
const WARNING_STATUS_COLORS: Record<string, string> = {
  '01': 'orange',
  '02': 'cyan',
  '03': 'default',
  '04': 'purple',
  '05': 'green',
};

/* ======================== 暗色主题 Tokens ======================== */
const T = {
  bg: '#080d25',
  cardBg: 'rgba(14, 22, 48, 0.92)',
  cardBorder: 'rgba(56, 189, 248, 0.12)',
  cardBorderHover: 'rgba(56, 189, 248, 0.28)',
  textPrimary: '#e2e8f0',
  textSecondary: '#94a3b8',
  accent: '#38bdf8',
  accentGreen: '#34d399',
  accentRed: '#f87171',
  accentAmber: '#fbbf24',
  accentPurple: '#a78bfa',
  splitLine: 'rgba(148, 163, 184, 0.08)',
};

/* ======================== 公共 ECharts 暗色基座 ======================== */
const darkBase = (overrides?: Record<string, any>) => ({
  backgroundColor: 'transparent',
  textStyle: { color: T.textSecondary },
  legend: { textStyle: { color: T.textSecondary, fontSize: 12 }, itemWidth: 10, itemHeight: 10, itemGap: 16 },
  tooltip: {
    backgroundColor: 'rgba(12, 20, 48, 0.96)',
    borderColor: T.cardBorder,
    textStyle: { color: T.textPrimary },
    ...overrides?.tooltip,
  },
});

/* ======================== 工具函数 ======================== */
const fmtWan = (v: number) => +(v / 10000).toFixed(2);
const fmtYuan = (v: number) => v.toLocaleString();

/* ======================== 组件 ======================== */

const Analysis: React.FC = () => {
  // 字典数据
  const { map: warningTypeMap, options: warningTypeOptions } = useDict('WARNING_TYPE');
  const { map: warningLevelMap, options: warningLevelOptions } = useDict('WARNING_LEVEL');
  const { map: warningStatusMap } = useDict('WARNING_STATUS');

  /* -------------------- 状态 -------------------- */
  const [allData, setAllData] = useState<WarningRecord[]>([]);
  const [loading, setLoading] = useState(false);
  const [dateRange, setDateRange] = useState<[dayjs.Dayjs, dayjs.Dayjs] | null>(() => {
    const end = dayjs();
    return [end.subtract(6, 'month'), end];
  });
  const [filterType, setFilterType] = useState<string>('');
  const [filterLevel, setFilterLevel] = useState<string>('');
  const [filterDept, setFilterDept] = useState<string>('');

  /* -------------------- 数据加载 -------------------- */
  const loadData = async () => {
    setLoading(true);
    try {
      const res: any = await queryWarningRecords(
        {
          warningType: filterType || undefined,
          startDate: dateRange?.[0]?.format('YYYY-MM-DD') || '',
          endDate: dateRange?.[1]?.format('YYYY-MM-DD') || '',
        },
        { pageSize: 99999, currentPage: 1 }
      );
      if (res.errorCode === '0' || res.errorCode === 0) {
        let rows: WarningRecord[] = (res.result.rows || []).map((item: any) => ({
          ...item,
          id: String(item.id || ''),
        }));
        if (filterLevel) rows = rows.filter(r => Number(r.warningLevel) === Number(filterLevel));
        if (filterDept) rows = rows.filter(r => r.deptName === filterDept);
        setAllData(rows);
      }
    } catch (e) { console.error('[Analysis]', e); }
    finally { setLoading(false); }
  };

  useEffect(() => { loadData(); }, []);

  /* -------------------- 派生指标（用 useMemo 缓存） -------------------- */
  const stats = useMemo(() => {
    const total = allData.length;
    const pending = allData.filter(r => r.warningStatus === '01').length;
    const overrun = allData.reduce((s, r) => s + Math.abs(Number(r.diffAmount ?? 0)), 0);
    const feeSum = allData.reduce((s, r) => s + (Number(r.totalFee) ?? 0), 0);
    const stdSum = allData.reduce((s, r) => s + (Number(r.drgPayStandard) ?? 0), 0);
    const deviationRate = stdSum > 0 ? (((feeSum - stdSum) / stdSum) * 100).toFixed(2) : '0';
    const highRisk = allData.filter(r => r.warningLevel === 3 && r.warningStatus === '01').length;
    const resolved = allData.filter(r => r.warningStatus === '05').length;
    return { total, pending, overrun, feeSum, stdSum, deviationRate, highRisk, resolved };
  }, [allData]);

  /* -------------------- 图表聚合函数（useMemo） -------------------- */

  // 预警类型分布
  const typeDist = useMemo(() => {
    const map: Record<string, number> = {};
    allData.forEach(r => {
      const k = getDictLabel(warningTypeMap, r.warningType);
      map[k] = (map[k] ?? 0) + 1;
    });
    return Object.entries(map).map(([name, value]) => ({ name, value }));
  }, [allData]);

  // 月度趋势
  const monthlyTrend = useMemo(() => {
    const map: Record<string, { cnt: number; amt: number }> = {};
    allData.forEach(r => {
      const m = (r.warningDateTime || r.warningDate || '').substring(0, 7);
      if (!m || m === '-') return;
      if (!map[m]) map[m] = { cnt: 0, amt: 0 };
      map[m].cnt += 1;
      map[m].amt += Math.abs(Number(r.diffAmount ?? 0));
    });
    const sorted = Object.entries(map).sort((a, b) => a[0].localeCompare(b[0]));
    return {
      months: sorted.map(e => e[0]),
      counts: sorted.map(e => e[1].cnt),
      amounts: sorted.map(e => fmtWan(e[1].amt)),
    };
  }, [allData]);

  // 科室排名
  const deptRank = useMemo(() => {
    const map: Record<string, { cnt: number; amt: number }> = {};
    allData.forEach(r => {
      const d = r.deptName || '未知';
      if (!map[d]) map[d] = { cnt: 0, amt: 0 };
      map[d].cnt += 1;
      map[d].amt += Math.abs(Number(r.diffAmount ?? 0));
    });
    return Object.entries(map)
      .map(([dept, v]) => ({ dept, count: v.cnt, amount: fmtWan(v.amt) }))
      .sort((a, b) => b.amount - a.amount)
      .slice(0, 10);
  }, [allData]);

  // DRG 组对比
  const drgComp = useMemo(() => {
    const map: Record<string, { fee: number; std: number }> = {};
    allData.forEach(r => {
      const c = r.drgCode || '未知';
      if (!map[c]) map[c] = { fee: 0, std: 0 };
      map[c].fee += Number(r.totalFee ?? 0);
      map[c].std += Number(r.drgPayStandard ?? 0);
    });
    return Object.entries(map)
      .map(([code, v]) => ({
        code,
        fee: fmtWan(v.fee),
        std: fmtWan(v.std),
        diff: fmtWan(v.fee - v.std),
      }))
      .sort((a, b) => b.fee - a.fee)
      .slice(0, 8);
  }, [allData]);

  // 最近6个月各类型趋势（堆叠面积图）
  const stackedTrend = useMemo(() => {
    const months = monthlyTrend.months.slice(-6);
    const typeNames = Object.values(warningTypeMap) as string[];
    const series = typeNames.map(t => {
      const data = months.map(m => {
        return allData.filter(r => {
          const rm = (r.warningDateTime || r.warningDate || '').substring(0, 7);
          return rm === m && getDictLabel(warningTypeMap, r.warningType) === t;
        }).length;
      });
      return { name: t, data };
    });
    return { months, series };
  }, [allData, monthlyTrend.months]);

  /* -------------------- ECharts option -------------------- */

  // 1) 环形图 - 预警类型分布
  const typePieOpt = useMemo(() => ({
    ...darkBase(),
    tooltip: { ...darkBase().tooltip, trigger: 'item', formatter: '{b}: {c} 条 ({d}%)' },
    legend: { ...darkBase().legend, bottom: 0, left: 'center' },
    series: [{
      type: 'pie',
      radius: ['62%', '82%'],
      center: ['50%', '44%'],
      avoidLabelOverlap: false,
      itemStyle: {
        borderRadius: 6,
        borderColor: T.bg,
        borderWidth: 3,
      },
      label: { show: false },
      emphasis: {
        label: { show: true, fontSize: 15, fontWeight: 'bold', color: T.textPrimary },
        scaleSize: 10,
        itemStyle: { shadowBlur: 20, shadowColor: 'rgba(56,189,248,0.5)' },
      },
      data: typeDist.map(d => ({
        ...d,
        itemStyle: { color: WARNING_TYPE_COLORS[d.name] },
      })),
      animationType: 'scale',
      animationEasing: 'elasticOut',
    }],
  }), [typeDist]);

  // 2) 月度趋势 - 双轴折线 + 面积
  const trendOpt = useMemo(() => ({
    ...darkBase(),
    tooltip: {
      ...darkBase().tooltip,
      trigger: 'axis',
      axisPointer: { type: 'cross', crossStyle: { color: T.textSecondary } },
      formatter: (ps: any[]) => {
        if (!ps?.length) return '';
        let h = `<div style="font-weight:700;margin-bottom:6px">${ps[0].axisValue}</div>`;
        ps.forEach(p => {
          h += `<div style="display:flex;align-items:center;gap:6px;margin:2px 0">
            <span style="width:10px;height:10px;border-radius:50%;background:${p.color};display:inline-block"></span>
            ${p.seriesName}: <b>${p.seriesName.includes('金额') ? p.value + '万' : p.value + '条'}</b>
          </div>`;
        });
        return h;
      },
    },
    legend: {
      ...darkBase().legend,
      data: ['预警数量', '超支金额(万)', '结余金额(万)'],
      top: 0,
    },
    grid: { left: '3%', right: '5%', bottom: '2%', top: '15%', containLabel: true },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: monthlyTrend.months,
      axisLine: { lineStyle: { color: T.splitLine } },
      axisTick: { show: false },
      axisLabel: { color: T.textSecondary, fontSize: 11 },
    },
    yAxis: [
      {
        type: 'value',
        name: '条',
        nameTextStyle: { color: T.textSecondary, fontSize: 11 },
        axisLabel: { color: T.textSecondary, fontSize: 11 },
        splitLine: { lineStyle: { color: T.splitLine } },
      },
      {
        type: 'value',
        name: '万元',
        nameTextStyle: { color: T.textSecondary, fontSize: 11 },
        axisLabel: { color: T.textSecondary, fontSize: 11 },
        splitLine: { show: false },
      },
    ],
    dataZoom: [{
      type: 'slider',
      start: 0,
      end: 100,
      height: 20,
      bottom: 2,
      borderColor: T.cardBorder,
      backgroundColor: 'rgba(14,22,48,0.6)',
      fillerColor: 'rgba(56,189,248,0.15)',
      textStyle: { color: T.textSecondary },
    }],
    series: [
      {
        name: '预警数量',
        type: 'line',
        smooth: true,
        symbol: 'circle',
        symbolSize: 7,
        data: monthlyTrend.counts,
        itemStyle: { color: T.accent },
        lineStyle: { width: 2.5 },
        areaStyle: {
          color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(56,189,248,0.28)' },
              { offset: 1, color: 'rgba(56,189,248,0.01)' },
            ] },
        },
        markLine: {
          silent: true,
          data: [{ type: 'average', name: '均值' }],
          lineStyle: { color: T.accent, type: 'dashed', opacity: 0.5 },
          label: { color: T.textSecondary, fontSize: 10 },
        },
      },
      {
        name: '超支金额(万)',
        type: 'line',
        smooth: true,
        symbol: 'diamond',
        symbolSize: 8,
        yAxisIndex: 1,
        data: monthlyTrend.amounts,
        itemStyle: { color: T.accentRed },
        lineStyle: { width: 2.5 },
        areaStyle: {
          color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(248,113,113,0.25)' },
              { offset: 1, color: 'rgba(248,113,113,0.01)' },
            ] },
        },
      },
    ],
  }), [monthlyTrend]);

  // 3) 科室排名 - 横向渐变柱状图
  const deptBarOpt = useMemo(() => ({
    ...darkBase(),
    tooltip: {
      ...darkBase().tooltip,
      trigger: 'axis',
      axisPointer: { type: 'shadow' },
      formatter: (ps: any[]) => {
        const p = ps?.[0];
        return `<b>${p?.name}</b><br/>超支金额: <b style="color:#f87171">${p?.value} 万元</b>`;
      },
    },
    grid: { left: '3%', right: '8%', bottom: '2%', top: '3%', containLabel: true },
    xAxis: {
      type: 'value',
      axisLabel: { color: T.textSecondary, fontSize: 11, formatter: '{value}w' },
      splitLine: { lineStyle: { color: T.splitLine } },
    },
    yAxis: {
      type: 'category',
      data: deptRank.map(d => d.dept).reverse(),
      axisLabel: { color: T.textPrimary, fontSize: 12, width: 90, overflow: 'truncate' },
      axisTick: { show: false },
      axisLine: { show: false },
    },
    series: [{
      type: 'bar',
      data: deptRank.map((d, i) => {
        const t = 0.82 - i * 0.06;
        return {
          value: d.amount,
          itemStyle: {
            color: { type: 'linear', x: 0, y: 0, x2: 1, y2: 0,
              colorStops: [
                { offset: 0, color: `rgba(248,113,113,${t})` },
                { offset: 1, color: `rgba(56,189,248,${t})` },
              ] },
            borderRadius: [0, 6, 6, 0],
          },
        };
      }).reverse(),
      barWidth: 18,
      label: { show: true, position: 'right', color: T.textSecondary, fontSize: 11, formatter: '{c} 万' },
      emphasis: {
        itemStyle: { shadowBlur: 12, shadowColor: 'rgba(248,113,113,0.5)' },
      },
    }],
  }), [deptRank]);

  // 4) DRG 组对比 - 分组柱状图
  const drgBarOpt = useMemo(() => ({
    ...darkBase(),
    tooltip: {
      ...darkBase().tooltip,
      trigger: 'axis',
      axisPointer: { type: 'shadow' },
      formatter: (ps: any[]) => {
        if (!ps?.length) return '';
        let h = `<div style="font-weight:700;margin-bottom:6px">DRG: ${ps[0].axisValue}</div>`;
        ps.forEach(p => {
          const nm = p.seriesName;
          const cl = nm === '超支差额' ? (p.value > 0 ? T.accentRed : T.accentGreen) : T.textPrimary;
          h += `<div style="color:${cl};margin:2px 0">${nm}: <b>${p.value} 万</b></div>`;
        });
        return h;
      },
    },
    legend: {
      ...darkBase().legend,
      data: ['实际费用(万)', '支付标准(万)', '超支差额(万)'],
      top: 0,
    },
    grid: { left: '3%', right: '4%', bottom: '2%', top: '15%', containLabel: true },
    xAxis: {
      type: 'category',
      data: drgComp.map(d => d.code),
      axisLabel: { color: T.textSecondary, fontSize: 11, rotate: 30 },
      axisTick: { show: false },
      axisLine: { lineStyle: { color: T.splitLine } },
    },
    yAxis: {
      type: 'value',
      name: '万元',
      nameTextStyle: { color: T.textSecondary, fontSize: 11 },
      axisLabel: { color: T.textSecondary, fontSize: 11 },
      splitLine: { lineStyle: { color: T.splitLine } },
    },
    series: [
      {
        name: '实际费用(万)',
        type: 'bar',
        barGap: '30%',
        data: drgComp.map(d => ({
          value: d.fee,
          itemStyle: {
            color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
              colorStops: [{ offset: 0, color: '#38bdf8' }, { offset: 1, color: '#0ea5e9' }] },
            borderRadius: [6, 6, 0, 0],
          },
        })),
      },
      {
        name: '支付标准(万)',
        type: 'bar',
        data: drgComp.map(d => ({
          value: d.std,
          itemStyle: {
            color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
              colorStops: [{ offset: 0, color: '#a78bfa' }, { offset: 1, color: '#7c3aed' }] },
            borderRadius: [6, 6, 0, 0],
          },
        })),
      },
      {
        name: '超支差额(万)',
        type: 'bar',
        data: drgComp.map(d => ({
          value: d.diff,
          itemStyle: {
            color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
              colorStops: [
                { offset: 0, color: d.diff > 0 ? '#f87171' : '#34d399' },
                { offset: 1, color: d.diff > 0 ? '#dc2626' : '#059669' },
              ] },
            borderRadius: [6, 6, 0, 0],
          },
        })),
      },
    ],
  }), [drgComp]);

  // 5) 堆叠面积图 - 各类型月度趋势
  const stackedOpt = useMemo(() => ({
    ...darkBase(),
    tooltip: { ...darkBase().tooltip, trigger: 'axis' },
    legend: { ...darkBase().legend, data: stackedTrend.series.map(s => s.name), top: 0 },
    grid: { left: '3%', right: '4%', bottom: '2%', top: '15%', containLabel: true },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: stackedTrend.months,
      axisLabel: { color: T.textSecondary, fontSize: 11 },
    },
    yAxis: {
      type: 'value',
      name: '条',
      nameTextStyle: { color: T.textSecondary },
      axisLabel: { color: T.textSecondary, fontSize: 11 },
      splitLine: { lineStyle: { color: T.splitLine } },
    },
    series: stackedTrend.series.map(s => ({
      name: s.name,
      type: 'line',
      smooth: true,
      stack: '总量',
      areaStyle: {},
      data: s.data,
      itemStyle: { color: WARNING_TYPE_COLORS[s.name] },
      lineStyle: { width: 1.5 },
      emphasis: { focus: 'series' },
    })),
  }), [stackedTrend]);

  /* -------------------- 表格列 -------------------- */
  const columns: ColumnsType<WarningRecord> = [
    { title: '预警流水号', dataIndex: 'warningNo', width: 170, ellipsis: true, render: v => <Text style={{ color: T.textSecondary, fontSize: 13 }}>{v}</Text> },
    { title: '级别', dataIndex: 'warningLevel', width: 60, align: 'center', render: (l: number) => <Tag color={WARNING_LEVEL_COLORS[String(l)]} style={{ borderRadius: 4 }}>{getDictLabel(warningLevelMap, String(l))}</Tag> },
    { title: '类型', dataIndex: 'warningType', width: 90, render: (t: string) => {
      const typeName = getDictLabel(warningTypeMap, t);
      return <Tag style={{ borderRadius: 4, background: 'transparent', border: `1px solid ${WARNING_TYPE_COLORS[typeName] || '#555'}`, color: T.textPrimary }}>{typeName}</Tag>;
    }},
    { title: '患者', dataIndex: 'patientName', width: 80 },
    { title: '科室', dataIndex: 'deptName', width: 110, render: (v: string) => v || '-' },
    { title: 'DRG', dataIndex: 'drgCode', width: 85, render: v => <Text code style={{ color: T.accent }}>{v}</Text> },
    { title: '医生', dataIndex: 'doctorName', width: 80, render: (v: string) => v || '-' },
    {
      title: '实际费用',
      dataIndex: 'totalFee',
      width: 110,
      align: 'right',
      sorter: (a, b) => (a.totalFee ?? 0) - (b.totalFee ?? 0),
      render: (v: number) => <Text strong style={{ color: T.textPrimary, fontSize: 13 }}>¥{fmtYuan(v ?? 0)}</Text>,
    },
    {
      title: '超支/结余',
      key: 'diff',
      width: 120,
      align: 'right',
      sorter: (a, b) => (a.diffAmount ?? 0) - (b.diffAmount ?? 0),
      render: (_, r) => {
        const d = r.diffAmount ?? 0;
        const isRed = d < 0;
        return (
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: 4 }}>
            {isRed ? <CaretDownOutlined style={{ color: T.accentRed }} /> : <CaretUpOutlined style={{ color: T.accentGreen }} />}
            <Text strong style={{ color: isRed ? T.accentRed : T.accentGreen, fontSize: 14 }}>¥{fmtYuan(Math.abs(d))}</Text>
          </div>
        );
      },
    },
    {
      title: '差异率',
      key: 'rate',
      width: 85,
      align: 'right',
      render: (_, r) => {
        const rate = r.diffRate ?? 0;
        return (
          <Progress
            percent={Math.min(Math.abs(rate), 100)}
            size="small"
            status={rate < 0 ? 'exception' : 'success'}
            format={() => `${rate > 0 ? '+' : ''}${rate}%`}
            style={{ margin: 0 }}
          />
        );
      },
    },
    {
      title: '状态',
      dataIndex: 'warningStatus',
      width: 80,
      align: 'center',
      render: (s: string) => <Tag color={WARNING_STATUS_COLORS[s]} style={{ borderRadius: 4 }}>{getDictLabel(warningStatusMap, s)}</Tag>,
    },
  ];

  const deptOptions = useMemo(() => [...new Set(allData.map(r => r.deptName).filter(Boolean))], [allData]);

  /* -------------------- KPI 卡片配置 -------------------- */
  const kpiCards = [
    { title: '总预警数', value: stats.total, icon: <WarningOutlined />, color: T.accent, bg: 'rgba(56,189,248,0.08)', trend: '', up: true },
    { title: '待处理', value: stats.pending, icon: <ThunderboltOutlined />, color: T.accentAmber, bg: 'rgba(251,191,36,0.08)', trend: '', up: false },
    { title: '高危预警', value: stats.highRisk, icon: <WarningOutlined />, color: T.accentRed, bg: 'rgba(248,113,113,0.08)', trend: stats.highRisk > 0 ? '紧急' : '无', up: false },
    { title: '费用总额', value: fmtWan(stats.feeSum), icon: <DollarOutlined />, color: T.accentGreen, bg: 'rgba(52,211,153,0.08)', suffix: '万', trend: '', up: true },
    { title: '超支总额', value: fmtWan(stats.overrun), icon: <FallOutlined />, color: T.accentRed, bg: 'rgba(248,113,113,0.08)', suffix: '万', trend: '', up: false },
    { title: '偏差率', value: stats.deviationRate, icon: <RiseOutlined />, color: T.accentPurple, bg: 'rgba(167,139,250,0.08)', suffix: '%', trend: '', up: parseFloat(stats.deviationRate) > 0 },
  ];

  /* ======================== 渲染 ======================== */
  return (
    <div className="dark-dashboard" style={{
      background: `radial-gradient(ellipse at 20% 50%, rgba(56,189,248,0.06) 0%, transparent 50%),
                    radial-gradient(ellipse at 80% 20%, rgba(167,139,250,0.05) 0%, transparent 50%),
                    ${T.bg}`,
      minHeight: '100%',
      padding: '20px 24px',
    }}>
      {/* ====== 标题栏 ====== */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
        <div>
          <div style={{ fontSize: 22, fontWeight: 700, color: T.textPrimary, letterSpacing: 1 }}>
            <AreaChartOutlined style={{ marginRight: 10, color: T.accent }} />
            费用预警分析
          </div>
          <div style={{ fontSize: 13, color: T.textSecondary, marginTop: 2 }}>
            实时监控 · 多维分析 · 智能预警
          </div>
        </div>
        <Space>
          <RangePicker
            locale={zhCN}
            style={{ width: 220 }}
            value={dateRange as any}
            onChange={d => setDateRange(d as any)}
            placeholder={['开始', '结束']}
            className="dark-picker"
            popupClassName="dark-select-popup"
          />
          <Select placeholder="预警类型" style={{ width: 120 }} allowClear value={filterType || undefined} onChange={v => setFilterType(v || '')}
            options={warningTypeOptions}
            popupClassName="dark-select-popup"
          />
          <Select placeholder="预警级别" style={{ width: 110 }} allowClear value={filterLevel || undefined} onChange={v => setFilterLevel(v || '')}
            options={warningLevelOptions}
            popupClassName="dark-select-popup"
          />
          <Select placeholder="科室" style={{ width: 130 }} allowClear showSearch value={filterDept || undefined} onChange={v => setFilterDept(v || '')}
            options={deptOptions.map(d => ({ value: d, label: d }))}
            popupClassName="dark-select-popup"
          />
          <Button
            type="primary"
            ghost
            icon={<ReloadOutlined />}
            onClick={loadData}
            style={{ borderColor: T.accent, color: T.accent }}
          >
            分析
          </Button>
        </Space>
      </div>

      {/* ====== KPI 统计卡片 ====== */}
      <Row gutter={[16, 16]} style={{ marginBottom: 20 }}>
        {kpiCards.map((item, idx) => (
          <Col xs={12} sm={8} md={8} lg={4} key={idx}>
            <div style={{
              background: T.cardBg,
              borderRadius: 12,
              border: `1px solid ${T.cardBorder}`,
              padding: '18px 20px',
              transition: 'all .3s',
              cursor: 'default',
              position: 'relative',
              overflow: 'hidden',
            }}
              onMouseEnter={e => { e.currentTarget.style.borderColor = T.cardBorderHover; e.currentTarget.style.boxShadow = `0 0 24px ${item.color}22`; }}
              onMouseLeave={e => { e.currentTarget.style.borderColor = T.cardBorder; e.currentTarget.style.boxShadow = 'none'; }}
            >
              {/* 装饰背景 */}
              <div style={{ position: 'absolute', right: -10, top: -10, width: 70, height: 70, borderRadius: '50%', background: item.bg, filter: 'blur(20px)' }} />
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', position: 'relative' }}>
                <div>
                  <div style={{ fontSize: 12, color: T.textSecondary, marginBottom: 8 }}>{item.title}</div>
                  <div style={{ fontSize: 26, fontWeight: 700, color: T.textPrimary, lineHeight: 1.1 }}>
                    {typeof item.value === 'number' ? item.value.toLocaleString() : item.value}
                    {item.suffix && <span style={{ fontSize: 14, fontWeight: 500, color: T.textSecondary, marginLeft: 2 }}>{item.suffix}</span>}
                  </div>
                </div>
                <div style={{ fontSize: 26, color: item.color, opacity: 0.7, marginTop: 2 }}>{item.icon}</div>
              </div>
              {/* 底部迷你进度条 */}
              {item.title === '高危预警' && (
                <Progress
                  percent={stats.total > 0 ? +((stats.highRisk / stats.total) * 100).toFixed(1) : 0}
                  showInfo={false}
                  size="small"
                  strokeColor={T.accentRed}
                  style={{ margin: '10px 0 0 0' }}
                />
              )}
              {item.title === '待处理' && (
                <Progress
                  percent={stats.total > 0 ? +((stats.pending / stats.total) * 100).toFixed(1) : 0}
                  showInfo={false}
                  size="small"
                  strokeColor={T.accentAmber}
                  style={{ margin: '10px 0 0 0' }}
                />
              )}
            </div>
          </Col>
        ))}
      </Row>

      {/* ====== 第一行：环形图 + 堆叠面积图 ====== */}
      <Row gutter={[16, 16]} style={{ marginBottom: 16 }}>
        <Col xs={24} lg={8}>
          <div style={{
            background: T.cardBg,
            borderRadius: 14,
            border: `1px solid ${T.cardBorder}`,
            padding: '16px 20px',
            height: 380,
          }}>
            <div style={{ fontSize: 15, fontWeight: 600, color: T.textPrimary, marginBottom: 8 }}>
              <PieChartOutlined style={{ color: T.accent, marginRight: 8 }} />预警类型分布
            </div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px 12px', marginBottom: 4 }}>
              {typeDist.map((d) => (
                <span key={d.name} style={{ fontSize: 11, color: WARNING_TYPE_COLORS[d.name], whiteSpace: 'nowrap' }}>
                  ● {d.name} {d.value}
                </span>
              ))}
            </div>
            <ReactECharts option={typePieOpt} style={{ height: 280 }} notMerge lazyUpdate />
          </div>
        </Col>
        <Col xs={24} lg={16}>
          <div style={{
            background: T.cardBg,
            borderRadius: 14,
            border: `1px solid ${T.cardBorder}`,
            padding: '16px 20px',
            height: 380,
          }}>
            <div style={{ fontSize: 15, fontWeight: 600, color: T.textPrimary, marginBottom: 4 }}>
              <AreaChartOutlined style={{ color: T.accentPurple, marginRight: 8 }} />各类型月度趋势（堆叠面积图）
            </div>
            <ReactECharts option={stackedOpt} style={{ height: 320 }} notMerge lazyUpdate />
          </div>
        </Col>
      </Row>

      {/* ====== 第二行：趋势图 + 科室排名 ====== */}
      <Row gutter={[16, 16]} style={{ marginBottom: 16 }}>
        <Col xs={24} lg={14}>
          <div style={{
            background: T.cardBg,
            borderRadius: 14,
            border: `1px solid ${T.cardBorder}`,
            padding: '16px 20px',
            height: 410,
          }}>
            <div style={{ fontSize: 15, fontWeight: 600, color: T.textPrimary, marginBottom: 4 }}>
              <LineChartOutlined style={{ color: T.accent, marginRight: 8 }} />预警总数 & 超支金额月度趋势
            </div>
            <ReactECharts option={trendOpt} style={{ height: 350 }} notMerge lazyUpdate />
          </div>
        </Col>
        <Col xs={24} lg={10}>
          <div style={{
            background: T.cardBg,
            borderRadius: 14,
            border: `1px solid ${T.cardBorder}`,
            padding: '16px 20px',
            height: 410,
          }}>
            <div style={{ fontSize: 15, fontWeight: 600, color: T.textPrimary, marginBottom: 4 }}>
              <BarChartOutlined style={{ color: T.accentRed, marginRight: 8 }} />科室超支 TOP10
            </div>
            <ReactECharts option={deptBarOpt} style={{ height: 350 }} notMerge lazyUpdate />
          </div>
        </Col>
      </Row>

      {/* ====== 第三行：DRG组对比 ====== */}
      <Row gutter={[16, 16]} style={{ marginBottom: 16 }}>
        <Col span={24}>
          <div style={{
            background: T.cardBg,
            borderRadius: 14,
            border: `1px solid ${T.cardBorder}`,
            padding: '16px 20px',
            height: 360,
          }}>
            <div style={{ fontSize: 15, fontWeight: 600, color: T.textPrimary, marginBottom: 4 }}>
              <BarChartOutlined style={{ color: T.accentPurple, marginRight: 8 }} />DRG组费用对比 TOP8（实际 vs 标准 vs 差额）
            </div>
            <ReactECharts option={drgBarOpt} style={{ height: 310 }} notMerge lazyUpdate />
          </div>
        </Col>
      </Row>

      {/* ====== 明细表格 ====== */}
      <div style={{
        background: T.cardBg,
        borderRadius: 14,
        border: `1px solid ${T.cardBorder}`,
        padding: '16px 20px',
      }}>
        <div style={{ fontSize: 15, fontWeight: 600, color: T.textPrimary, marginBottom: 12 }}>
          <LineChartOutlined style={{ color: T.accent, marginRight: 8 }} />预警明细数据（共 {allData.length} 条）
        </div>
        <Spin spinning={loading}>
          <Table
            columns={columns}
            dataSource={allData}
            rowKey="id"
            scroll={{ x: 1400, y: 480 }}
            size="middle"
            pagination={{
              defaultPageSize: 15,
              showSizeChanger: true,
              pageSizeOptions: ['10', '15', '30', '50', '100'],
              showTotal: (t) => <Text style={{ color: T.textSecondary }}>共 {t} 条</Text>,
            }}
            locale={{ emptyText: <Text style={{ color: T.textSecondary }}>暂无预警数据</Text> }}
            style={{ background: 'transparent' }}
          />
        </Spin>
      </div>

      {/* ====== 暗色主题样式注入（仅作用于本页面 .dark-dashboard 内） ====== */}
      <style>{`
        /* DatePicker */
        .dark-dashboard .dark-picker,
        .dark-dashboard .dark-picker input { background: rgba(14,22,48,0.8) !important; border-color: ${T.cardBorder} !important; color: ${T.textPrimary} !important; }
        .dark-dashboard .dark-picker .ant-picker-suffix { color: ${T.textSecondary} !important; }

        /* Select 输入框 */
        .dark-dashboard .ant-select-selector { background: rgba(14,22,48,0.8) !important; border-color: ${T.cardBorder} !important; color: ${T.textPrimary} !important; }
        .dark-dashboard .ant-select-arrow { color: ${T.textSecondary} !important; }

        /* Select/Picker 下拉面板（渲染于 body，用 popupClassName 控制） */
        .dark-select-popup { background: #0e1630 !important; }
        .dark-select-popup .ant-select-item,
        .dark-select-popup .ant-picker-cell { color: ${T.textSecondary} !important; }
        .dark-select-popup .ant-select-item-option-selected { background: rgba(56,189,248,0.12) !important; color: ${T.accent} !important; }

        /* Pagination */
        .dark-dashboard .ant-pagination-item,
        .dark-dashboard .ant-pagination-prev .ant-pagination-item-link,
        .dark-dashboard .ant-pagination-next .ant-pagination-item-link {
          background: rgba(14,22,48,0.6) !important; border-color: ${T.cardBorder} !important; color: ${T.textSecondary} !important;
        }
        .dark-dashboard .ant-pagination-item-active { background: ${T.accent}22 !important; border-color: ${T.accent} !important; }
        .dark-dashboard .ant-pagination-item-active a { color: ${T.accent} !important; }

        /* Table */
        .dark-dashboard .ant-table { background: transparent !important; color: ${T.textPrimary} !important; }
        .dark-dashboard .ant-table-thead > tr > th {
          background: rgba(14,22,48,0.6) !important;
          color: ${T.textSecondary} !important;
          border-bottom: 1px solid ${T.cardBorder} !important;
          font-size: 12px !important;
          font-weight: 600 !important;
        }
        .dark-dashboard .ant-table-tbody > tr > td {
          border-bottom: 1px solid ${T.splitLine} !important;
          color: ${T.textPrimary} !important;
          font-size: 13px !important;
        }
        .dark-dashboard .ant-table-tbody > tr:hover > td { background: rgba(56,189,248,0.04) !important; }

        /* Spin & Tag */
        .dark-dashboard .ant-spin-dot-item { background: ${T.accent} !important; }
        .dark-dashboard .ant-tag { background: transparent !important; }
      `}</style>
    </div>
  );
};

export default Analysis;
