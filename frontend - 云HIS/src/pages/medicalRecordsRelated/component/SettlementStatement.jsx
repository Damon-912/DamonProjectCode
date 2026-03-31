/*
 * Create:      柿子
 * CreateDate:  2026/01/23
 * Describe：   结算清单
 * */
import React, { useEffect, useState, forwardRef, useImperativeHandle } from 'react';
import { Modal, Spin, Row, Col } from 'antd';
import { staticSelectData } from '../js/staticSelectData';
import '../style/index.less';

const SettlementStatement = (props, ref) => {
    const userData = React.$getUserData();
    const [visible, setVisible] = useState(false);
    const [spinLoading, setSpinLoading] = useState(false);
    const [propParams, setPropParams] = useState({});
    const [itemInfoAmount, setItemInfoAmount] = useState({});

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible
    }));

    // 修改弹窗状态
    const modifyVisible = (visible, params = {}) => {
        setPropParams(params);
        setVisible(visible);
    };

    useEffect(() => {
        if (Object.keys(propParams).length > 0) {
            setSpinLoading(false);
            handleItemInfoTotalAmount();
        }
    }, [propParams]);

    // 映射关系数据渲染 separator: 分隔符 right: 右边距 endMarker: 结束符号
    const renderMap = (data, separator, right, endMarker) => {
        return data.map((item, index) => {
            return (
                <span key={item?.id || index} style={{ marginRight: right || '' }}>
                    {item.id + (separator === 'N' || separator === 'none' ? '' : (separator || ' ')) + item.descripts + (data.length - 1 > index ? (endMarker === 'N' || endMarker === 'none' ? '' : (endMarker || '，')) : '')}
                </span>
            );
        });
    };

    // 列表数据处理
    const handleEmrTableDataProcessing = (data, minQty) => {
        let result = [];
        if (data && Array.isArray(data)) {
            result = [...data];
            let resultLen = data?.length || 0;
            if (resultLen < minQty) {
                for (let i = 0; i < minQty - resultLen; i++) {
                    result.push({});
                }
            }
        }
        console.log('result', result)
        return result;
    };

    // 计算项目合计金额
    const handleItemInfoTotalAmount = () => {
        const data = propParams?.item_info || propParams?.itemInfo || [];
        let amtTotal = 0, claaSumfeeTotal = 0, clabAmtTotal = 0, fulamtOwnpayAmtTotal = 0, othAmtTotal = 0;
        if (data && Array.isArray(data)) {
            data.forEach(item => {
                amtTotal += (item?.amt || 0);
                claaSumfeeTotal += (item?.claaSumfee || item?.claa_sumfee || 0);
                clabAmtTotal += (item?.clabAmt || item?.clab_amt || 0);
                fulamtOwnpayAmtTotal += (item?.fulamtOwnpayAmt || item?.fulamt_ownpay_amt || 0);
                othAmtTotal += (item?.othAmt || item?.oth_amt || 0);
            });
        }
        setItemInfoAmount({
            amtTotal,
            claaSumfeeTotal,
            clabAmtTotal,
            fulamtOwnpayAmtTotal,
            othAmtTotal
        })
    };

    const { width, title } = props;

    return (
        <div>
            <Modal
                open={visible}
                width={width || '46vw'}
                title={title || '结算清单预览'}
                footer={null}
                onCancel={() => modifyVisible(false)}
            >
                <Spin tip="加载中..." spinning={spinLoading}>
                    <div className="settlement-statement" style={{ maxHeight: '76vh', overflow: 'auto' }}>
                        <h2 className="textCenter" style={{ marginBottom: '10px' }}>医疗保障基金结算清单</h2>
                        <Row style={{ marginBottom: '4px' }}>
                            <Col span={16}></Col>
                            <Col span={8}>
                                <span className="emr-label">清单流水号</span>
                                {propParams?.mdtrtSn || propParams?.mdtrt_sn || ''}
                            </Col>
                        </Row>
                        <Row style={{ marginBottom: '4px' }}>
                            <Col span={8}>
                                <span className="emr-label">定点医疗机构名称</span>
                            </Col>
                            <Col span={8}>
                                <span className="emr-label">定点医疗机构代码</span>
                            </Col>
                            <Col span={8}>
                                <span className="emr-label">医保结算等级</span>
                            </Col>
                        </Row>
                        <Row style={{ marginBottom: '4px' }}>
                            <Col span={8}>
                                <span className="emr-label">医保编号</span>
                            </Col>
                            <Col span={8}>
                                <span className="emr-label">病案号</span>
                                {propParams?.medcasNo || propParams?.medcas_no || ''}
                            </Col>
                            <Col span={8}>
                                <span className="emr-label">申报时间</span>
                                {propParams?.dclaTime || propParams?.dcla_time || ''}
                            </Col>
                        </Row>
                        <table border="1" className="emr-table">
                            <colgroup>
                                {/* 定义18列，每列宽度相等 */}
                                {Array.from({ length: 24 }).map((_, i) => (
                                    <col key={i} />
                                ))}
                            </colgroup>
                            <tbody>
                                <tr>
                                    <td colSpan="24" className="emr-title">
                                        一、基本信息
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row>
                                            <Col span={5}>
                                                <span className="emr-label">姓名</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '12px' }}>
                                                    {propParams?.psn_name || propParams?.psnName || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">姓别</span>
                                                <span className="emr-value" style={{ width: '36px', marginRight: '12px' }}>
                                                    {propParams?.gend || ''}
                                                </span>
                                                {renderMap(staticSelectData?.gender || [])}
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label" style={{ marginLeft: '12px' }}>出生日期</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 98px)', marginRight: '12px' }}>
                                                    {propParams?.brdy || ''}
                                                </span>
                                            </Col>
                                            <Col span={4}>
                                                <span className="emr-label">年龄</span>
                                                <span className="emr-value" style={{ width: '56px', marginRight: '12px' }}>
                                                    {propParams?.age || ''}
                                                </span>
                                            </Col>
                                            <Col span={4}>
                                                <span className="emr-label">国籍</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 52px)', marginRight: '12px' }}>
                                                    {propParams?.ntly || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={5}>
                                                <span className="emr-label">民族</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '12px' }}>
                                                    {propParams?.naty_name || propParams?.naty || ''}
                                                </span>
                                            </Col>
                                            <Col span={7}>
                                                <span className="emr-label">患者证件类型</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 108px)', marginRight: '12px' }}>
                                                    {propParams?.certType || propParams?.cert_type || ''}
                                                </span>
                                            </Col>
                                            <Col span={12}>
                                                <span className="emr-label">患者证件号码</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 108px)' }}>
                                                    {propParams?.certNo || propParams?.cert_no || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={5}>
                                                <span className="emr-label">职业</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '12px' }}>
                                                    {propParams?.prfs || ''}
                                                </span>
                                            </Col>
                                            <Col span={19}>
                                                <span className="emr-label">现住址</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 66px)' }}>
                                                    {propParams?.currAddr || propParams?.curr_addr || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={19}>
                                                <span className="emr-label">工作单位及地址</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 122px)', marginRight: '12px' }}>
                                                    {propParams?.emprAddr || propParams?.empr_addr || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">单位电话</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '12px' }}>
                                                    {propParams?.emprTel || propParams?.empr_tel || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={6}>
                                                <span className="emr-label">联系人姓名</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '12px' }}>
                                                    {propParams?.conerName || propParams?.coner_name || ''}
                                                </span>
                                            </Col>
                                            <Col span={4}>
                                                <span className="emr-label">关系</span>
                                                <span className="emr-value" style={{ width: '56px', marginRight: '12px' }}>
                                                    {propParams?.conerRltsCode || propParams?.coner_rlts_code || ''}
                                                </span>
                                            </Col>
                                            <Col span={9}>
                                                <span className="emr-label">地址</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 54px)', marginRight: '12px' }}>
                                                    {propParams?.conerAddr || propParams?.coner_addr || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">电话</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 52px)', marginRight: '12px' }}>
                                                    {propParams?.conerTel || propParams?.coner_tel || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={5}>
                                                <span className="emr-label">医保类型</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '12px' }}></span>
                                            </Col>
                                            <Col span={7}>
                                                <span className="emr-label">特殊人员类型</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '12px' }}></span>
                                            </Col>
                                            <Col span={12}>
                                                <span className="emr-label">参保地</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 66px)' }}></span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="24" className="emr-title">
                                        二、门诊特慢病诊疗信息
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={16}>
                                                <span className="emr-label">诊断科别</span>
                                                <span className="emr-value">
                                                    {propParams?.opspDiagCaty || propParams?.opsp_diag_caty || ''}
                                                </span>
                                            </Col>
                                            <Col span={8}>
                                                <span className="emr-label">就诊日期</span>
                                                <span className="emr-value">
                                                    {propParams?.opspMdtrtDate || propParams?.opsp_mdtrt_date || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={5}>
                                                <span className="emr-label">病种名称</span>
                                                <span className="emr-value"></span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">病种代码</span>
                                                <span className="emr-value"></span>
                                            </Col>
                                            <Col span={7}>
                                                <span className="emr-label">手术及操作名称</span>
                                                <span className="emr-value"></span>
                                            </Col>
                                            <Col span={7}>
                                                <span className="emr-label">手术及操作代码</span>
                                                <span className="emr-value"></span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="24" className="emr-title">
                                        三、住院诊疗信息
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">住院医疗类型</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '24px' }}>

                                                </span>
                                                {renderMap(staticSelectData?.medicalType || [])}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">入院途径</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '24px' }}>
                                                    {propParams?.admWay || propParams?.adm_way || ''}
                                                </span>
                                                {renderMap(staticSelectData?.admissionRoute || [])}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">治疗类别</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '24px' }}></span>
                                                {renderMap(staticSelectData?.treatmentType || [])}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={8}>
                                                <span className="emr-label">入院时间</span>
                                                <span className="emr-value" style={{ width: '156px', marginRight: '12px' }}>
                                                    {propParams?.admTime || propParams?.adm_time || ''}
                                                </span>
                                            </Col>
                                            <Col span={8}>
                                                <span className="emr-label">入院科别</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '12px' }}>
                                                    {propParams?.admCaty || propParams?.adm_caty || ''}
                                                </span>
                                            </Col>
                                            <Col span={8}>
                                                <span className="emr-label">转院科别</span>
                                                <span className="emr-value" style={{ width: '126px', marginRight: '12px' }}>
                                                    {propParams?.refldeptDept || propParams?.refldept_dept || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={8}>
                                                <span className="emr-label">出院时间</span>
                                                <span className="emr-value" style={{ width: '156px', marginRight: '12px' }}>
                                                    {propParams?.dscgTime || propParams?.dscg_time || ''}
                                                </span>
                                            </Col>
                                            <Col span={8}>
                                                <span className="emr-label">出院科别</span>
                                                <span className="emr-value" style={{ width: '86px', marginRight: '12px' }}>
                                                    {propParams?.dscgCaty || propParams?.dscg_caty || ''}
                                                </span>
                                            </Col>
                                            <Col span={8}>
                                                <span className="emr-label">实际住院</span>
                                                <span className="emr-value" style={{ width: '36px', marginRight: '12px' }}>
                                                    {propParams?.iptDays || propParams?.ipt_days || ''}
                                                </span>
                                                天
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row>
                                            <Col span={16}>
                                                <span className="emr-label">门（急）诊诊断（西医诊断）</span>
                                                <span className="emr-value">
                                                    {propParams?.otpWmDise || propParams?.otp_wm_dise || ''}
                                                </span>
                                            </Col>
                                            <Col span={8}>
                                                <span className="emr-label">疾病代码</span>
                                                <span className="emr-value">
                                                    {propParams?.wmDiseCode || propParams?.wm_dise_code || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={16}>
                                                <span className="emr-label">门（急）诊诊断（中医诊断）</span>
                                                <span className="emr-value">
                                                    {propParams?.otpTcmDise || propParams?.otp_tcm_dise || ''}
                                                </span>
                                            </Col>
                                            <Col span={8}>
                                                <span className="emr-label">疾病代码</span>
                                                <span className="emr-value">
                                                    {propParams?.tcmDiseCode || propParams?.tcm_dise_code || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                {/* 诊断信息 */}
                                <tr>
                                    <td rowSpan="2" colSpan="8" className="textCenter">出院诊断</td>
                                    <td rowSpan="2" colSpan="8" className="textCenter">疾病编码</td>
                                    <td colSpan="8" className="textCenter">入院病情</td>
                                </tr>
                                <tr>
                                    <td colSpan="2" className="textCenter">有</td>
                                    <td colSpan="2" className="textCenter">临床不确定</td>
                                    <td colSpan="2" className="textCenter">情况不明</td>
                                    <td colSpan="2" className="textCenter">无</td>
                                </tr>
                                {handleEmrTableDataProcessing(propParams?.dise_info || propParams?.diseInfo || [], 5).map((item, index) => {
                                    return (
                                        <tr key={index}>
                                            <td colSpan="8" className="textCenter">
                                                {/* 出院诊断 */}
                                                {item?.diagName || item?.diag_name || ''}</td>
                                            <td colSpan="8" className="textCenter">
                                                {/* 疾病编码 */}
                                                {item?.diagCode || item?.diag_code || ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 入院病情 */}
                                                {(item?.admCondType || item?.adm_cond_type || '') == '1' ? '√' : ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 临床不确定 */}
                                                {(item?.admCondType || item?.adm_cond_type || '') == '2' ? '√' : ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 情况不明 */}
                                                {(item?.admCondType || item?.adm_cond_type || '') == '3' ? '√' : ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 无 */}
                                                {(item?.admCondType || item?.adm_cond_type || '') == '4' ? '√' : ''}
                                            </td>
                                        </tr>
                                    )
                                })}
                                <tr>
                                    <td colSpan="24">
                                        <span className="emr-label">诊断计数</span>
                                        <span className="emr-value" style={{ width: '36px', marginRight: '12px' }}>
                                            {(propParams?.dise_info || propParams?.diseInfo || [])?.length || 0}
                                        </span>
                                    </td>
                                </tr>
                                {/* 手术信息 */}
                                {handleEmrTableDataProcessing(propParams?.oprnInfo || propParams?.oprn_info || [], 1).map((item, index) => {
                                    return (
                                        <React.Fragment key={index}>
                                            <tr>
                                                <td colSpan="7" className="textCenter">
                                                    主要手术及操作名称
                                                </td>
                                                <td colSpan="5" className="textCenter">
                                                    主要手术及操作代码
                                                </td>
                                                <td colSpan="2" className="textCenter">
                                                    麻醉方式
                                                </td>
                                                <td colSpan="2" className="textCenter">
                                                    术者医师姓名
                                                </td>
                                                <td colSpan="3" className="textCenter">
                                                    术者医师代码
                                                </td>
                                                <td colSpan="2" className="textCenter">
                                                    麻醉医师姓名
                                                </td>
                                                <td colSpan="3" className="textCenter">
                                                    麻醉医师代码
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colSpan="7" className="textCenter">
                                                    {/* 主要手术及操作名称 */}
                                                    {item?.oprnOprtName || item?.oprn_oprt_name || ''}
                                                </td>
                                                <td colSpan="5" className="textCenter">
                                                    {/* 主要手术及操作代码 */}
                                                    {item?.oprnOprtCode || item?.oprn_oprt_code || ''}
                                                </td>
                                                <td colSpan="2" className="textCenter">
                                                    {/* 麻醉方式 */}
                                                    {item?.anstWay || item?.anst_way || ''}
                                                </td>
                                                <td colSpan="2" className="textCenter">
                                                    {/* 术者医师姓名 */}
                                                    {item?.operDrName || item?.oper_dr_name || ''}
                                                </td>
                                                <td colSpan="3" className="textCenter">
                                                    {/* 术者医师代码 */}
                                                    {item?.operDrCode || item?.oper_dr_code || ''}
                                                </td>
                                                <td colSpan="2" className="textCenter">
                                                    {/* 麻醉医师姓名 */}
                                                    {item?.anstDrName || item?.anst_dr_name || ''}
                                                </td>
                                                <td colSpan="3" className="textCenter">
                                                    {/* 麻醉医师代码 */}
                                                    {item?.anstDrCode || item?.anst_dr_code || ''}
                                                </td>
                                            </tr>
                                            <tr className="emr-pat-info">
                                                <td colSpan="24">
                                                    <Row style={{ marginBottom: '4px' }}>
                                                        <Col span={9}>
                                                            <span className="emr-label">手术操作日期</span>
                                                            <span className="emr-value" style={{ width: 'calc(100% - 106px)' }}>
                                                                {item?.oprnOprtBegntime || item?.oprn_oprt_begntime || ''}
                                                            </span>
                                                        </Col>
                                                        <Col span={15}>
                                                            <span className="emr-label">麻醉起始时间</span>
                                                            <span className="emr-value" style={{ width: 'calc(100% - 106px)' }}>
                                                                {item?.anstBegntime || item?.anst_begntime || '--'}
                                                                至
                                                                {item?.anstEndtime || item?.anst_endtime || '--'}
                                                            </span>
                                                        </Col>
                                                    </Row>
                                                </td>
                                            </tr>
                                        </React.Fragment>
                                    )
                                })}
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">手术及操作代码计数</span>
                                                <span className="emr-value" style={{ width: '36px' }}>
                                                    {(propParams?.oprnInfo || propParams?.oprn_info || [])?.length || 0}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">呼吸机使用时间</span>
                                                <span className="emr-value" style={{ width: '186px' }}>
                                                    {propParams?.ventUsedDura || propParams?.vent_used_dura || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span style={{ display: 'inline-block', width: '168px' }}>颅脑损伤换着昏迷时间</span>
                                                <span className="emr-label">入院前</span>
                                                <span className="emr-value" style={{ width: '186px' }}>
                                                    {propParams?.pwcryBfadmComaDura || propParams?.pwcry_bfadm_coma_dura || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span style={{ display: 'inline-block', width: '168px' }}></span>
                                                <span className="emr-label">入院后</span>
                                                <span className="emr-value" style={{ width: '186px' }}>
                                                    {propParams?.pwcryAfadmComaDura || propParams?.pwcry_afadm_coma_dura || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="8">
                                        <span className="textCenter">症监护病房类型（CCU、NICU、ECU、SICU、PICU、RICU、ICU(综合)、其他</span>
                                    </td>
                                    <td colSpan="6" className="textCenter">
                                        <div>
                                            进重症监护室时间
                                        </div>
                                        <div>
                                            {'('}
                                            <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>年
                                            <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>月
                                            <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>日
                                            <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>时
                                            <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>分
                                            {')'}
                                        </div>
                                    </td>
                                    <td colSpan="6" className="textCenter">
                                        <div>
                                            出重症监护室时间
                                        </div>
                                        <div>
                                            {'('}
                                            <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>年
                                            <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>月
                                            <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>日
                                            <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>时
                                            <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>分
                                            {')'}
                                        </div>
                                    </td>
                                    <td colSpan="4" className="textCenter">
                                        合计
                                        {'('}
                                        <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>时
                                        <span className="emr-value" style={{ width: '18px', height: '12px' }}></span>分
                                        {')'}
                                    </td>
                                </tr>
                                {(propParams?.icuInfo || propParams?.icu_info || []).map((item, index) => {
                                    return (
                                        <tr key={index}>
                                            <td colSpan="8">
                                                <span className="textCenter">
                                                    {/* 症监护病房类型 */}
                                                    {item?.scsCutdWardType || item?.scs_cutd_ward_type || ''}
                                                </span>
                                            </td>
                                            <td colSpan="6">
                                                <span className="textCenter">
                                                    {/* 进重症监护室时间 */}
                                                    {item?.scsCutdInpoolTime || item?.scs_cutd_inpool_time || ''}
                                                </span>
                                            </td>
                                            <td colSpan="6">
                                                <span className="textCenter">
                                                    {/* 出重症监护室时间 */}
                                                    {item?.scsCutdExitTime || item?.scs_cutd_exit_time || ''}
                                                </span>
                                            </td>
                                            <td colSpan="4">
                                                <span className="textCenter">
                                                    {/* 合计 */}
                                                    {item?.scsCutdSumDura || item?.scs_cutd_sum_dura || ''}
                                                </span>
                                            </td>
                                        </tr>
                                    )
                                })}
                                <tr>
                                    <td colSpan="8" className="textCenter">
                                        <span>输血品种</span>
                                    </td>
                                    <td colSpan="12" className="textCenter">
                                        <span>输血量</span>
                                    </td>
                                    <td colSpan="4" className="textCenter">
                                        <span>输血计量单位</span>
                                    </td>
                                </tr>
                                {(propParams?.bldinfo || propParams?.bld_info || []).map((item, index) => {
                                    return (
                                        <tr key={index}>
                                            <td colSpan="8">
                                                <span className="textCenter">
                                                    {/* 输血品种 */}
                                                    {item?.bldCat || item?.bld_cat || ''}
                                                </span>
                                            </td>
                                            <td colSpan="12">
                                                <span className="textCenter">
                                                    {/* 输血量 */}
                                                    {item?.bldAmt || item?.bld_amt || ''}
                                                </span>
                                            </td>
                                            <td colSpan="4">
                                                <span className="textCenter">
                                                    {/* 输血计量单位 */}
                                                    {item?.bldUnt || item?.bld_unt || ''}
                                                </span>
                                            </td>
                                        </tr>
                                    )
                                })}
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={6}>
                                                <span className="textCenter">特级护理天数</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 120px)', marginRight: '24px' }}>
                                                    {propParams?.spgaUurscareDays || propParams?.spga_uurscare_days || ''}
                                                </span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="textCenter">一级护理天数</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 120px)', marginRight: '24px' }}>
                                                    {propParams?.lv1NurscareDays || propParams?.lv1_nurscare_days || ''}
                                                </span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="textCenter">二级护理天数</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 120px)', marginRight: '24px' }}>
                                                    {propParams?.scdnurscareDays || propParams?.scdnurscare_days || ''}
                                                </span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="textCenter">三级护理天数</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 120px)' }}>
                                                    {propParams?.lv3NurscareDays || propParams?.lv3_nurscare_days || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">离院方式</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.dscgWay || propParams?.dscg_way || ''}
                                                </span>
                                                {renderMap(staticSelectData?.leaveHospitalMethod || [])}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">是否有出院31天内再住院计划</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.dscg31daysRinpFlag || propParams?.dscg_31days_rinp_flag || ''}
                                                </span>
                                                {renderMap(staticSelectData?.readmissionPlan || [])}
                                                ，目的：
                                                <span className="emr-value" style={{ width: 'calc(100% - 362px)' }}>
                                                    {propParams?.dscg31daysRinpPup || propParams?.dscg_31days_rinp_pup || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="12">
                                        <Row>
                                            <Col span={24}>
                                                <span className="emr-label">主诊医师姓名</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 108px)' }}>
                                                    {propParams?.chfpdrName || propParams?.chfpdr_name || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">责任护士姓名</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 108px)' }}>
                                                    {propParams?.respNursName || propParams?.resp_nurs_name || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                    <td colSpan="12">
                                        <Row>
                                            <Col span={24}>
                                                <span className="emr-label">主诊医师代码</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 108px)' }}>
                                                    {propParams?.chfpdrCode || propParams?.chfpdr_code || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">责任护士代码</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 108px)' }}>
                                                    {propParams?.respNursCode || propParams?.resp_nurs_code || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="24" className="emr-title">
                                        四、医疗收费信息
                                    </td>
                                </tr>
                                <tr className="emr-pat-info">
                                    <td colSpan="12">
                                        <Row>
                                            <Col span={24}>
                                                <span className="emr-label">业务流水号</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 94px)' }}>
                                                    {propParams?.bizSn || propParams?.biz_sn || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={24}>
                                                <span className="emr-label">票据代码</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 80px)' }}>
                                                    {propParams?.billCode || propParams?.bill_code || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">票据号码</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 80px)' }}>
                                                    {propParams?.billNo || propParams?.bill_no || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                    <td colSpan="12">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">结算期间</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 80px)' }}>
                                                    {propParams?.setlBegnDate || propParams?.setl_begn_date || ''}
                                                    至
                                                    {propParams?.setlEndDate || propParams?.setl_end_date || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="9" className="textCenter">
                                        项目名称
                                    </td>
                                    <td colSpan="3" className="textCenter">
                                        金额
                                    </td>
                                    <td colSpan="3" className="textCenter">
                                        甲类
                                    </td>
                                    <td colSpan="3" className="textCenter">
                                        乙类
                                    </td>
                                    <td colSpan="3" className="textCenter">
                                        自费
                                    </td>
                                    <td colSpan="3" className="textCenter">
                                        其他
                                    </td>
                                </tr>
                                {handleEmrTableDataProcessing(propParams?.item_info || propParams?.itemInfo || [], 1).map((item, index) => {
                                    return (
                                        <tr key={index}>
                                            <td colSpan="9" className="textCenter">
                                                {/* 项目名称 */}
                                                {item?.medChrgitm || item?.med_chrgitm || ''}
                                            </td>
                                            <td colSpan="3" className="textCenter">
                                                {/* 金额 */}
                                                {item?.amt || ''}
                                            </td>
                                            <td colSpan="3" className="textCenter">
                                                {/* 甲类 */}
                                                {item?.claaSumfee || item?.claa_sumfee || ''}
                                            </td>
                                            <td colSpan="3" className="textCenter">
                                                {/* 乙类 */}
                                                {item?.clabAmt || item?.clab_amt || ''}
                                            </td>
                                            <td colSpan="3" className="textCenter">
                                                {/* 自费 */}
                                                {item?.fulamtOwnpayAmt || item?.fulamt_ownpay_amt || ''}
                                            </td>
                                            <td colSpan="3" className="textCenter">
                                                {/* 其他 */}
                                                {item?.othAmt || item?.oth_amt || ''}
                                            </td>
                                        </tr>
                                    )
                                })}
                                <tr>
                                    <td colSpan="9" className="textCenter">
                                        合计金额
                                    </td>
                                    <td colSpan="3" className="textCenter">
                                        {/* 金额 */}
                                        {itemInfoAmount?.amtTotal || itemInfoAmount?.amt_total || ''}
                                    </td>
                                    <td colSpan="3" className="textCenter">
                                        {/* 甲类 */}
                                        {itemInfoAmount?.claaSumfeeTotal || itemInfoAmount?.claa_sumfee_total || ''}
                                    </td>
                                    <td colSpan="3" className="textCenter">
                                        {/* 乙类 */}
                                        {itemInfoAmount?.clabAmtTotal || itemInfoAmount?.clab_amt_total || ''}
                                    </td>
                                    <td colSpan="3" className="textCenter">
                                        {/* 自费 */}
                                        {itemInfoAmount?.fulamtOwnpayAmtTotal || itemInfoAmount?.fulamt_ownpay_amt_total || ''}
                                    </td>
                                    <td colSpan="3" className="textCenter">
                                        {/* 其他 */}
                                        {itemInfoAmount?.othAmtTotal || itemInfoAmount?.oth_amt_total || ''}
                                    </td>
                                </tr>
                                <tr>
                                    {(propParams?.payInfo || propParams?.pay_info || []).map((item, index) => {
                                        return (
                                            <React.Fragment key={index}>
                                                <td colSpan="9" className="textCenter">
                                                    {/* 基金支付类型 */}
                                                    {item?.fundPayType || item?.fund_pay_type || ''}
                                                </td>
                                                <td colSpan="3" className="textCenter">
                                                    {/* 基金支付金额 */}
                                                    {item?.fundPayamt || item?.fund_payamt || ''}
                                                </td>
                                            </React.Fragment>
                                        )
                                    })}
                                </tr>
                                {/* <tr>
                                    <td colSpan="9" className="textCenter">医保统筹基金支付</td>
                                    <td colSpan="3" className="textCenter">0.00</td>
                                    <td colSpan="3" rowspan="4" className="textCenter">个人负担</td>
                                    <td colSpan="3" rowspan="2" className="textCenter">个人自付</td>
                                    <td colSpan="6" rowspan="2" className="textCenter">0.00</td>
                                </tr>
                                <tr>
                                    <td colSpan="9" className="textCenter">医疗救助支付</td>
                                    <td colSpan="3" className="textCenter">0.00</td>
                                </tr>
                                <tr>
                                    <td colSpan="3" rowspan="5" className="textCenter">其他支付</td>
                                    <td colSpan="6" className="textCenter">大额医疗补助</td>
                                    <td colSpan="3" className="textCenter">0.00</td>
                                    <td colSpan="3" rowspan="2" className="textCenter">个人自费</td>
                                    <td colSpan="6" rowspan="2" className="textCenter">0.00</td>
                                </tr>
                                <tr>
                                    <td colSpan="6" className="textCenter">企业补充保险</td>
                                    <td colSpan="3" className="textCenter">0.00</td>
                                </tr>
                                <tr>
                                    <td colSpan="6" className="textCenter">城乡大病</td>
                                    <td colSpan="3" className="textCenter">0.00</td>
                                    <td colSpan="3" rowspan="3" className="textCenter">个人支付</td>
                                    <td colSpan="3" rowspan="2" className="textCenter">个人账户支付</td>
                                    <td colSpan="6" rowspan="2" className="textCenter">0.00</td>
                                </tr>
                                <tr>
                                    <td colSpan="6" className="textCenter">城乡大病补充</td>
                                    <td colSpan="3" className="textCenter">0.00</td>
                                </tr>
                                <tr>
                                    <td colSpan="6" className="textCenter">特惠保补偿</td>
                                    <td colSpan="3" className="textCenter">0.00</td>
                                    <td colSpan="3" className="textCenter">个人现金</td>
                                    <td colSpan="6" className="textCenter">0.00</td>
                                </tr> */}
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={24}>
                                                <span className="emr-label">医保支付方式</span>
                                                <span className="emr-value" style={{ width: '56px', marginRight: '12px' }}>
                                                    {propParams?.hiPaymtd || propParams?.hi_paymtd || ''}
                                                </span>
                                                {renderMap(staticSelectData?.insurancePaymentMethod || [])}
                                            </Col>
                                        </Row>

                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <div className="emr-pat-info" style={{ marginTop: '6px' }}>
                            <Row>
                                <Col span={12}>
                                    <span className="emr-label">定点医疗机构填报部门</span>
                                    {/* <span className="emr-value" style={{ width: 'calc(100% - 164px)' }}> */}
                                    <span>
                                        {propParams?.medinsFillDept || propParams?.medins_fill_dept || ''}
                                    </span>
                                </Col>
                                <Col span={7}>
                                    <span className="emr-label">医保经办机构</span>
                                    {/* <span className="emr-value" style={{ width: 'calc(100% - 108px)' }}> */}
                                    <span>

                                    </span>
                                </Col>
                                <Col span={5}>
                                    <span className="emr-label">代码</span>
                                    {/* <span className="emr-value" style={{ width: 'calc(100% - 52px)' }}> */}
                                    <span>

                                    </span>
                                </Col>
                            </Row>
                            <Row>
                                <Col span={12}>
                                    <span className="emr-label">定点医疗机构填报人</span>
                                    {/* <span className="emr-value" style={{ width: 'calc(100% - 150px)' }}> */}
                                    <span>
                                        {propParams?.medinsFillPsn || propParams?.medins_fill_psn || ''}
                                    </span>
                                </Col>
                                <Col span={7}>
                                    <span className="emr-label">医保机构经办人</span>
                                    {/* <span className="emr-value" style={{ width: 'calc(100% - 122px)' }}> */}
                                    <span>

                                    </span>
                                </Col>
                                <Col span={5}>
                                    <span className="emr-label">代码</span>
                                    {/* <span className="emr-value" style={{ width: 'calc(100% - 52px)' }}> */}
                                    <span>

                                    </span>
                                </Col>
                            </Row>
                        </div>
                    </div>
                </Spin>
            </Modal>
        </div >
    )
};

export default forwardRef(SettlementStatement);