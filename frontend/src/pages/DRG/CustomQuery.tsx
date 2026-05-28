import { useState, useCallback, useEffect, useRef } from 'react';
import { 
  Card, Form, InputNumber, Select, Button, Space, 
  Table, Descriptions, Tag, Alert, Row, Col,
  Input, Typography, message, Modal, List, Collapse
} from 'antd';
import { 
  PlayCircleOutlined, ReloadOutlined, PlusOutlined, DeleteOutlined,
  MedicineBoxOutlined, UserOutlined, ScissorOutlined, BankOutlined,
  CalendarOutlined
} from '@ant-design/icons';
import { drgGroup, convertResultToLowerCamel, type DiagnosisInfoLowerCamel, type OperationInfoLowerCamel, type DRGGroupResultLowerCamel } from '@/api/drgGrouping';
import { queryMedInsuIcdInfo, getProvinceData, getCityData, type MedInsuIcdItem, type ProvinceItem, type CityItem } from '@/api/basicData';
import { queryHospitals, type HospitalItem } from '@/api/hospital';
import { useDict } from '../../hooks/useDict';
import { getDictLabel } from '../../utils/dict';


const { Option } = Select;
const { Text } = Typography;

const { useForm } = Form;

/**
 * 自定义DRG分组查询页面
 * 功能：用户手动输入患者就诊信息，调用02010001接口获取分组结果
 */
const DRGCustomQuery: React.FC = () => {
  // 字典数据
  const { options: yesNoOptions } = useDict('YES_NO_FLAG');
  const { options: sexOptions } = useDict('SEX');
  const { options: dischargeTypeOptions } = useDict('DISCHARGE_TYPE');

  const [form] = useForm();
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<DRGGroupResultLowerCamel | null>(null);
  const [diagnoses, setDiagnoses] = useState<DiagnosisInfoLowerCamel[]>([
    { mainFlag: 1, diagSn: 1, diagCode: '', diagName: '' }
  ]);
  const [operations, setOperations] = useState<OperationInfoLowerCamel[]>([
    { mainFlag: '1', oprnSn: 1, oprnCode: '', oprnName: '' }
  ]);

  // 使用useRef存储最新的diagnoses和operations值，解决闭包问题
  const diagnosesRef = useRef(diagnoses);
  const operationsRef = useRef(operations);

  // 当diagnoses或operations更新时，同步更新ref
  useEffect(() => {
    diagnosesRef.current = diagnoses;
  }, [diagnoses]);

  useEffect(() => {
    operationsRef.current = operations;
  }, [operations]);

  // ICD查询相关状态
  const [icdModalOpen, setIcdModalOpen] = useState(false);
  const [icdQueryType, setIcdQueryType] = useState<'diagnosis' | 'operation'>('diagnosis');
  const [currentIndex, setCurrentIndex] = useState<number>(-1);
  const [icdSearchCode, setIcdSearchCode] = useState('');
  const [icdSearchName, setIcdSearchName] = useState('');
  const [icdLoading, setIcdLoading] = useState(false);
  const [icdResults, setIcdResults] = useState<MedInsuIcdItem[]>([]);

  // 医疗机构查询相关状态
  const [hospitals, setHospitals] = useState<HospitalItem[]>([
    { ID: '', hospitalID: '', code: '', descripts: '', hospTypeID: '', hospNatureID: '', provIDID: 0, cityIDID: 0, areaIDID: 0, active: 'Y', organizationCode: '', businesslicense: '', policyTypeID: '', policyTypeDesc: '' }
  ]);
  const [hospitalModalOpen, setHospitalModalOpen] = useState(false);
  const [hospitalLoading, setHospitalLoading] = useState(false);
  const [hospitalResults, setHospitalResults] = useState<HospitalItem[]>([]);
  const [hospitalCurrentIndex, setHospitalCurrentIndex] = useState<number>(-1);

  // 使用useRef存储最新的hospitals值
  const hospitalsRef = useRef(hospitals);
  useEffect(() => {
    hospitalsRef.current = hospitals;
  }, [hospitals]);

  // 省、市下拉数据状态
  const [provinceList, setProvinceList] = useState<ProvinceItem[]>([]);
  const [cityList, setCityList] = useState<CityItem[]>([]);
  const [provinceLoading, setProvinceLoading] = useState(false);
  const [cityLoading, setCityLoading] = useState(false);

  // 加载省数据
  const loadProvinces = useCallback(async () => {
    setProvinceLoading(true);
    try {
      const res = await getProvinceData();
      if (res.errorCode === '0' && res.result) {
        setProvinceList(res.result);
      }
    } catch (error) {
      message.error('加载省数据失败');
    } finally {
      setProvinceLoading(false);
    }
  }, []);

  // 加载市数据
  const loadCities = useCallback(async (provinceId: string) => {
    if (!provinceId) {
      setCityList([]);
      return;
    }
    setCityLoading(true);
    try {
      const res = await getCityData(provinceId);
      if (res.errorCode === '0' && res.result) {
        setCityList(res.result);
      }
    } catch (error) {
      message.error('加载市数据失败');
    } finally {
      setCityLoading(false);
    }
  }, []);

  // 初始化加载省数据
  useEffect(() => {
    loadProvinces();
  }, [loadProvinces]);

  // 省选择变化
  const handleProvinceChange = (value: string) => {
    form.setFieldsValue({ City: undefined }); // 清空市的选择
    setCityList([]);
    if (value) {
      loadCities(value);
    }
  };

  // 提交分组查询 - 使用小驼峰格式
  const handleSubmit = async (values: any) => {
    try {
      setLoading(true);
      setResult(null);

      // 先清理无效记录并排序
      cleanupAll();

      // 校验主诊断信息
      const mainDiag = diagnoses.find(d => d.mainFlag === 1);
      if (!mainDiag || !mainDiag.diagCode || !mainDiag.diagCode.trim()) {
        message.error('请填写主诊断信息（诊断代码不能为空）');
        setLoading(false);
        return;
      }

      // 校验患者有效年龄和新生儿天数,不能同时为0
      const age = values.Age || 0;
      const ageGroupDays = values.AgeGroupDays || 0;
      if (age === 0 && ageGroupDays === 0) {
        message.error('患者有效年龄和新生儿天数不能同时为0,请至少填写一项');
        setLoading(false);
        return;
      }

      // 校验新生儿天数大于0时,年龄不能大于1
      if (ageGroupDays > 0 && age > 1) {
        message.error('当新生儿天数大于0时,年龄不能大于1岁');
        setLoading(false);
        return;
      }

      // 校验当前医疗费用总额 - 如果不为空且不为0，则必须是有效金额
      const totalCost = values.TotalCost;
      if (totalCost !== undefined && totalCost !== null && totalCost !== '' && Number(totalCost) !== 0) {
        const totalCostNum = Number(totalCost);
        if (isNaN(totalCostNum)) {
          message.error('当前医疗费用总额必须是有效数字');
          setLoading(false);
          return;
        }
        if (totalCostNum <= 0) {
          message.error('当前医疗费用总额必须是大于0的金额');
          setLoading(false);
          return;
        }
      }

      // 获取主手术代码
      const mainOprn = operations.find(o => o.mainFlag === '1');

      // 根据新生儿天数自动设置新生儿标志
      const newbornFlag = values.AgeGroupDays && values.AgeGroupDays > 0 ? '1' : '0';
      form.setFieldValue('NewbornFlag', newbornFlag);

      // 获取市对应的行政区划代码（从 cityList 中查找）
      const selectedCityCode = values.City 
        ? (cityList.find(c => c.id === values.City)?.code || '')
        : '';

      // 构建医疗机构信息数组，从已选中的医疗机构中提取code和descripts
      const hospInfo = hospitals
        .filter(h => h.code) // 只选择有code的医疗机构
        .map(h => ({
          code: h.code,
          name: h.descripts,
        }));

      // 校验：如果医疗机构信息不为空，则省市和分组方案年份必选
      if (hospInfo.length > 0 && (!values.Province || !values.City)) {
        message.error('选择医疗机构时，参保省份、参保城市为必选项');
        setLoading(false);
        return;
      }
      if (hospInfo.length > 0 && !values.GroupYear) {
        message.error('选择医疗机构时，分组方案年份为必填项');
        setLoading(false);
        return;
      }

      // 构建小驼峰入参
      // 注意：diseInfo 和 oprnInfo 必须传递，即使是空数组
      // 主诊断和主手术信息已包含在数组对象内
      const lowerParams: any = {
        mainDiagnosisCode: mainDiag?.diagCode || '',
        mainOperationCode: mainOprn?.oprnCode || '',
        sex: values.Sex,
        age: values.Age,
        ageGroupDays: values.AgeGroupDays,
        newbornFlag: newbornFlag,
        respiratorTime: values.RespiratorTime,
        ecmoFlag: values.ECMOFlag,
        transplantFlag: values.TransplantFlag,
        marrowTransplantFlag: values.MarrowTransplantFlag,
        hivFlag: values.HIVFlag,
        traumaLevel: values.TraumaLevel,
        department: values.Department,
        dischargeType: values.DischargeType,
        hospitalDays: values.HospitalDays,
        totalCost: values.TotalCost,
        // 就医地行政区划代码（取自市下拉框的 code 值）
        insuranceAreaCode: selectedCityCode,
        // diseInfo 和 oprnInfo 必须传递，即使是空数组
        // 主诊断和主手术信息已包含在数组对象内
        diseInfo: diagnoses,
        oprnInfo: operations,
        // 医疗机构信息数组，即使为空也要传递
        hospInfo: hospInfo,
        // 分组方案年份
        groupYear: values.GroupYear,
      };

      // 直接调用接口（内部会自动转换大小驼峰）
      const res = await drgGroup(lowerParams);
      
      if (res.errorCode === '0' || res.errorCode === '00') {
        // 转换为小驼峰格式返回
        setResult(convertResultToLowerCamel(res));
        message.success('分组成功');
      } else {
        message.error(res.errorMessage || '分组失败');
      }
    } catch (error: any) {
      console.error('分组失败:', error);
      message.error(error.message || '分组失败，请检查网络连接');
    } finally {
      setLoading(false);
    }
  };

  // 重置表单
  const handleReset = () => {
    form.resetFields();
    setDiagnoses([{ mainFlag: 1, diagSn: 1, diagCode: '', diagName: '' }]);
    setOperations([]);
    setHospitals([]);
    setResult(null);
  };

  // 清理并排序诊断信息
  const cleanupDiagnoses = () => {
    // 过滤掉无效记录（代码和名称为空的）
    let validDiagnoses = diagnoses.filter(d => 
      d.diagCode && d.diagCode.trim() !== '' && d.diagName && d.diagName.trim() !== ''
    );
    
    // 如果没有有效记录，保留一个空记录
    if (validDiagnoses.length === 0) {
      validDiagnoses = [{ mainFlag: 1, diagSn: 1, diagCode: '', diagName: '' }];
    }
    
    // 根据主诊断排序（主诊断放第一个）
    const mainDiagIndex = validDiagnoses.findIndex(d => d.mainFlag === 1);
    if (mainDiagIndex > 0) {
      const mainDiag = validDiagnoses[mainDiagIndex];
      validDiagnoses.splice(mainDiagIndex, 1);
      validDiagnoses.unshift(mainDiag);
    }
    
    // 重新排序号
    validDiagnoses = validDiagnoses.map((d, i) => ({ ...d, diagSn: i + 1 }));
    
    // 确保第一个为主诊断
    if (validDiagnoses.length > 0 && validDiagnoses[0].mainFlag !== 1) {
      validDiagnoses[0].mainFlag = 1;
    }
    
    setDiagnoses(validDiagnoses);
  };

  // 清理并排序手术信息
  const cleanupOperations = () => {
    // 过滤掉无效记录（代码和名称为空的）
    let validOperations = operations.filter(o => 
      o.oprnCode && o.oprnCode.trim() !== '' && o.oprnName && o.oprnName.trim() !== ''
    );
    
    // 根据主手术排序（主手术放第一个）
    const mainOprnIndex = validOperations.findIndex(o => o.mainFlag === '1');
    if (mainOprnIndex > 0) {
      const mainOprn = validOperations[mainOprnIndex];
      validOperations.splice(mainOprnIndex, 1);
      validOperations.unshift(mainOprn);
    }
    
    // 重新排序号
    validOperations = validOperations.map((o, i) => ({ ...o, oprnSn: i + 1 }));
    
    setOperations(validOperations);
  };

  // 统一清理函数
  const cleanupAll = () => {
    cleanupDiagnoses();
    cleanupOperations();
  };

  // 添加诊断
  const addDiagnosis = () => {
    // 检查是否已存在未填写的空记录
    const hasEmptyRecord = diagnoses.some(d => !d.diagCode || d.diagCode.trim() === '');
    if (hasEmptyRecord) {
      message.warning('已存在未填写的诊断记录，请先完善后再添加');
      return;
    }
    const newSn = diagnoses.length + 1;
    setDiagnoses([...diagnoses, { mainFlag: 0, diagSn: newSn, diagCode: '', diagName: '' }]);
  };

  // 删除诊断
  const removeDiagnosis = (index: number) => {
    if (diagnoses.length === 1) {
      message.warning('至少保留一个诊断');
      return;
    }
    const newDiagnoses = diagnoses.filter((_, i) => i !== index);
    // 重新编号
    setDiagnoses(newDiagnoses.map((d, i) => ({ ...d, diagSn: i + 1 })));
  };

  // 更新诊断
  const updateDiagnosis = (index: number, field: keyof DiagnosisInfoLowerCamel, value: any) => {
    let newDiagnoses = [...diagnoses];
    newDiagnoses[index] = { ...newDiagnoses[index], [field]: value };

    // 如果是设置为主诊断且当前不是第一个，调整顺序
    if (field === 'mainFlag' && value === 1) {
      form.setFieldValue('MainDiagnosisCode', newDiagnoses[index].diagCode);
      // 清除其他的主诊断标志
      newDiagnoses.forEach((d, i) => {
        if (i !== index && d.mainFlag === 1) {
          newDiagnoses[i] = { ...d, mainFlag: 0 };
        }
      });
      
      // 如果当前不是第一个，将其移到第一个位置
      if (index !== 0) {
        const selectedItem = newDiagnoses[index];
        // 移除当前项
        newDiagnoses.splice(index, 1);
        // 插入到第一个位置
        newDiagnoses.unshift(selectedItem);
        // 重新排序号
        newDiagnoses = newDiagnoses.map((d, i) => ({ ...d, diagSn: i + 1 }));
      }
      
      setDiagnoses(newDiagnoses);
      return;
    }

    setDiagnoses(newDiagnoses);
  };

  // 添加手术
  const addOperation = () => {
    // 检查是否已存在未填写的空记录
    const hasEmptyRecord = operations.some(o => !o.oprnCode || o.oprnCode.trim() === '');
    if (hasEmptyRecord) {
      message.warning('已存在未填写的手术记录，请先完善后再添加');
      return;
    }
    const newSn = operations.length + 1;
    // 如果是第一条手术记录，默认设置为主手术
    const isFirstOperation = operations.length === 0;
    const newOperation = { 
      mainFlag: isFirstOperation ? '1' : '0', 
      oprnSn: newSn, 
      oprnCode: '', 
      oprnName: '' 
    };
    setOperations([...operations, newOperation]);
  };

  // 删除手术
  const removeOperation = (index: number) => {
    const newOperations = operations.filter((_, i) => i !== index);
    setOperations(newOperations.map((o, i) => ({ ...o, oprnSn: i + 1 })));
  };

  // 更新手术
  const updateOperation = (index: number, field: keyof OperationInfoLowerCamel, value: any) => {
    let newOperations = [...operations];
    newOperations[index] = { ...newOperations[index], [field]: value };

    // 如果是设置为主手术且当前不是第一个，调整顺序
    if (field === 'mainFlag' && value === '1') {
      form.setFieldValue('MainOperationCode', newOperations[index].oprnCode);
      // 清除其他的主手术标志
      newOperations.forEach((o, i) => {
        if (i !== index && o.mainFlag === '1') {
          newOperations[i] = { ...o, mainFlag: '0' };
        }
      });
      
      // 如果当前不是第一个，将其移到第一个位置
      if (index !== 0) {
        const selectedItem = newOperations[index];
        // 移除当前项
        newOperations.splice(index, 1);
        // 插入到第一个位置
        newOperations.unshift(selectedItem);
        // 重新排序号
        newOperations = newOperations.map((o, i) => ({ ...o, oprnSn: i + 1 }));
      }
      
      setOperations(newOperations);
      return;
    }

    setOperations(newOperations);
  };

  // 添加医疗机构
  const addHospital = () => {
    // 检查是否已存在未填写的空记录
    const hasEmptyRecord = hospitals.some(h => !h.code || h.code.trim() === '');
    if (hasEmptyRecord) {
      message.warning('已存在未填写的医疗机构记录，请先完善后再添加');
      return;
    }
    setHospitals([...hospitals, { ID: '', hospitalID: '', code: '', descripts: '', hospTypeID: '', hospNatureID: '', provIDID: 0, cityIDID: 0, areaIDID: 0, active: 'Y', organizationCode: '', businesslicense: '', policyTypeID: '', policyTypeDesc: '' }]);
  };

  // 删除医疗机构
  const removeHospital = (index: number) => {
    setHospitals(hospitals.filter((_, i) => i !== index));
  };

  // 更新医疗机构
  const updateHospital = (index: number, field: keyof HospitalItem, value: any) => {
    // 如果是更新医疗机构代码，校验唯一性
    if (field === 'code' && value && value.trim() !== '') {
      const isDuplicate = hospitals.some((h, i) => i !== index && h.code === value.trim());
      if (isDuplicate) {
        message.warning('该医疗机构代码已存在，请勿重复添加');
        return;
      }
    }

    const newHospitals = [...hospitals];
    newHospitals[index] = { ...newHospitals[index], [field]: value };
    setHospitals(newHospitals);
  };

  // 打开医疗机构查询弹窗并自动查询
  const openHospitalSearch = async (index: number) => {
    setHospitalCurrentIndex(index);
    
    // 获取当前行的医疗机构代码和名称
    const currentHospitals = hospitalsRef.current;
    const code = currentHospitals[index]?.code || '';
    const desc = currentHospitals[index]?.descripts || '';
    
    // 自动查询医疗机构，传入 code 和 desc
    setHospitalLoading(true);
    try {
      const res = await queryHospitals(
        {
          desc: desc || undefined,
          active: 'Y',
        },
        { pageSize: 20, currentPage: 1 }
      );
      if (String(res.errorCode) === '0' && res.result) {
        const rows = res.result.rows || [];
        if (rows.length === 1) {
          // 只有1条数据，直接填充
          const item = rows[0];
          const newCode = item.organizationCode || item.code;
          
          // 检查是否已存在相同的医疗机构代码
          const isDuplicate = hospitalsRef.current.some((h, i) => i !== index && h.code === newCode);
          if (isDuplicate) {
            message.warning(`医疗机构代码 ${newCode} 已存在，请勿重复添加`);
            setHospitalResults(rows);
            setHospitalModalOpen(true);
            return;
          }
          
          const newHospitals = [...hospitalsRef.current];
          newHospitals[index] = { 
            ...newHospitals[index], 
            ...item,
            code: newCode
          };
          setHospitals(newHospitals);
          message.success(`已选择：${newCode} ${item.descripts}`);
        } else if (rows.length > 1) {
          // 多条数据，弹出选择框
          setHospitalResults(rows);
          setHospitalModalOpen(true);
        } else {
          // 没有数据
          message.info('未找到匹配的医疗机构');
          setHospitalResults([]);
          setHospitalModalOpen(true);
        }
      } else {
        message.error(res.errorMessage || '查询失败');
        setHospitalModalOpen(true);
      }
    } catch (error) {
      message.error('查询医疗机构失败');
      setHospitalModalOpen(true);
    } finally {
      setHospitalLoading(false);
    }
  };

  // 选择医疗机构
  const selectHospital = (item: HospitalItem) => {
    if (hospitalCurrentIndex >= 0) {
      const newCode = item.organizationCode || item.code;
      
      // 检查是否已存在相同的医疗机构代码
      const isDuplicate = hospitals.some((h, i) => i !== hospitalCurrentIndex && h.code === newCode);
      if (isDuplicate) {
        message.warning(`医疗机构代码 ${newCode} 已存在，请勿重复添加`);
        setHospitalModalOpen(false);
        return;
      }
      
      const newHospitals = [...hospitals];
      // 使用 organizationCode 作为 code 字段的值
      newHospitals[hospitalCurrentIndex] = { 
        ...newHospitals[hospitalCurrentIndex], 
        ...item,
        code: newCode
      };
      setHospitals(newHospitals);
    }
    setHospitalModalOpen(false);
    message.success(`已选择：${item.organizationCode || item.code} ${item.descripts}`);
  };

  // 打开ICD查询弹窗 - 诊断
  const openIcdSearchForDiagnosis = async (index: number) => {
    setIcdQueryType('diagnosis');
    setCurrentIndex(index);
    // 使用ref获取最新的diagnoses值，解决闭包问题
    const currentDiagnoses = diagnosesRef.current;
    const code = currentDiagnoses[index]?.diagCode || '';
    const name = currentDiagnoses[index]?.diagName || '';
    setIcdSearchCode(code);
    setIcdSearchName(name);
    setIcdResults([]);
    
    // 如果有诊断代码或名称，自动查询
    if (code || name) {
      setIcdLoading(true);
      try {
        // 优先使用名称查询，如果没有名称则使用代码
        const queryParams: any = {
          versionNo: 'ICD-10',
          provinceId: '36',
          cityId: '371',
        };
        
        // 如果输入的是名称（包含中文），用desc查询
        // 如果输入的是代码（如I21.0），用code查询
        if (name && /[\u4e00-\u9fa5]/.test(name)) {
          // 包含中文，按名称查询
          queryParams.desc = name;
        } else if (code) {
          // 按代码查询
          queryParams.code = code;
        } else if (name) {
          // 其他情况也按名称查询
          queryParams.desc = name;
        }
        
        const res = await queryMedInsuIcdInfo(
          queryParams,
          { pageSize: 10, currentPage: 1 }
        );
        if (res.errorCode === '0' && res.result) {
          const rows = res.result.rows || [];
          if (rows.length === 1) {
            // 只有1条数据，直接赋值
            const item = rows[0];
            
            // 检查是否已存在相同的诊断代码
            const isDuplicate = diagnosesRef.current.some((d, i) => i !== index && d.diagCode === item.code);
            if (isDuplicate) {
              message.warning(`诊断代码 ${item.code} 已存在，请勿重复添加`);
              setIcdResults(rows);
              setIcdModalOpen(true);
              return;
            }
            
            // 同时更新代码和名称，避免setState异步问题
            const newDiagnoses = [...diagnosesRef.current];
            newDiagnoses[index] = { 
              ...newDiagnoses[index], 
              diagCode: item.code, 
              diagName: item.desc 
            };
            setDiagnoses(newDiagnoses);
            // 如果是主诊断，更新MainDiagnosisCode
            if (newDiagnoses[index]?.mainFlag === 1) {
              form.setFieldValue('MainDiagnosisCode', item.code);
            }
            message.success(`已选择：${item.code} ${item.desc}`);
          } else if (rows.length > 1) {
            // 多条数据，弹出选择框
            setIcdResults(rows);
            setIcdModalOpen(true);
          } else {
            // 没有数据
            message.info('未找到匹配的ICD编码');
            setIcdModalOpen(true);
          }
        } else {
          message.error(res.errorMessage || '查询失败');
          setIcdModalOpen(true);
        }
      } catch (error) {
        message.error('查询ICD编码失败');
        setIcdModalOpen(true);
      } finally {
        setIcdLoading(false);
      }
    } else {
      // 没有输入内容，直接打开弹窗
      setIcdModalOpen(true);
    }
  };

  // 打开ICD查询弹窗 - 手术
  const openIcdSearchForOperation = async (index: number) => {
    setIcdQueryType('operation');
    setCurrentIndex(index);
    // 使用ref获取最新的operations值，解决闭包问题
    const currentOperations = operationsRef.current;
    const code = currentOperations[index]?.oprnCode || '';
    const name = currentOperations[index]?.oprnName || '';
    setIcdSearchCode(code);
    setIcdSearchName(name);
    setIcdResults([]);
    
    // 如果有手术代码或名称，自动查询
    if (code || name) {
      setIcdLoading(true);
      try {
        // 优先使用名称查询，如果没有名称则使用代码
        const queryParams: any = {
          versionNo: 'ICD-9',
          provinceId: '36',
          cityId: '371',
        };
        
        // 如果输入的是名称（包含中文），用desc查询
        // 如果输入的是代码（如99.01），用code查询
        if (name && /[\u4e00-\u9fa5]/.test(name)) {
          // 包含中文，按名称查询
          queryParams.desc = name;
        } else if (code) {
          // 按代码查询
          queryParams.code = code;
        } else if (name) {
          // 其他情况也按名称查询
          queryParams.desc = name;
        }
        
        const res = await queryMedInsuIcdInfo(
          queryParams,
          { pageSize: 10, currentPage: 1 }
        );
        if (res.errorCode === '0' && res.result) {
          const rows = res.result.rows || [];
          if (rows.length === 1) {
            // 只有1条数据，直接赋值
            const item = rows[0];
            
            // 检查是否已存在相同的手术代码
            const isDuplicate = operationsRef.current.some((o, i) => i !== index && o.oprnCode === item.code);
            if (isDuplicate) {
              message.warning(`手术代码 ${item.code} 已存在，请勿重复添加`);
              setIcdResults(rows);
              setIcdModalOpen(true);
              return;
            }
            
            // 同时更新代码和名称，避免setState异步问题
            const newOperations = [...operationsRef.current];
            newOperations[index] = { 
              ...newOperations[index], 
              oprnCode: item.code, 
              oprnName: item.desc 
            };
            setOperations(newOperations);
            // 如果是主手术，更新MainOperationCode
            if (newOperations[index]?.mainFlag === '1') {
              form.setFieldValue('MainOperationCode', item.code);
            }
            message.success(`已选择：${item.code} ${item.desc}`);
          } else if (rows.length > 1) {
            // 多条数据，弹出选择框
            setIcdResults(rows);
            setIcdModalOpen(true);
          } else {
            // 没有数据
            message.info('未找到匹配的ICD编码');
            setIcdModalOpen(true);
          }
        } else {
          message.error(res.errorMessage || '查询失败');
          setIcdModalOpen(true);
        }
      } catch (error) {
        message.error('查询ICD编码失败');
        setIcdModalOpen(true);
      } finally {
        setIcdLoading(false);
      }
    } else {
      // 没有输入内容，直接打开弹窗
      setIcdModalOpen(true);
    }
  };

  // 查询ICD编码 - 诊断用ICD-10，手术用ICD-9
  const handleIcdSearch = useCallback(async () => {
    if (!icdSearchCode && !icdSearchName) {
      message.warning('请输入ICD编码或名称进行查询');
      return;
    }
    setIcdLoading(true);
    try {
      // ICD-10: 诊断, ICD-9: 手术
      const version = icdQueryType === 'diagnosis' ? 'ICD-10' : 'ICD-9';
      const res = await queryMedInsuIcdInfo(
        {
          versionNo: version,
          provinceId: '36',
          cityId: '371',
          code: icdSearchCode || undefined,
          desc: icdSearchName || undefined,
        },
        { pageSize: 10, currentPage: 1 }
      );
      if (res.errorCode === '0' && res.result) {
        setIcdResults(res.result.rows || []);
        if (res.result.rows?.length === 0) {
          message.info('未找到匹配的ICD编码');
        }
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch (error) {
      message.error('查询ICD编码失败');
    } finally {
      setIcdLoading(false);
    }
  }, [icdSearchCode, icdSearchName, icdQueryType]);

  // 选择ICD编码
  const selectIcd = (item: MedInsuIcdItem) => {
    if (icdQueryType === 'diagnosis' && currentIndex >= 0) {
      // 检查是否已存在相同的诊断代码
      const isDuplicate = diagnoses.some((d, i) => i !== currentIndex && d.diagCode === item.code);
      if (isDuplicate) {
        message.warning(`诊断代码 ${item.code} 已存在，请勿重复添加`);
        setIcdModalOpen(false);
        return;
      }
      
      // 诊断：直接更新状态，避免多次调用导致的异步问题
      const newDiagnoses = [...diagnoses];
      newDiagnoses[currentIndex] = { 
        ...newDiagnoses[currentIndex], 
        diagCode: item.code, 
        diagName: item.desc 
      };
      
      // 如果是主诊断，更新MainDiagnosisCode，并确保只有一个主诊断
      if (newDiagnoses[currentIndex]?.mainFlag === 1) {
        form.setFieldValue('MainDiagnosisCode', item.code);
        // 清除其他主诊断标志
        newDiagnoses.forEach((d, i) => {
          if (i !== currentIndex && d.mainFlag === 1) {
            newDiagnoses[i] = { ...d, mainFlag: 0 };
          }
        });
      }
      setDiagnoses(newDiagnoses);
      
    } else if (icdQueryType === 'operation' && currentIndex >= 0) {
      // 检查是否已存在相同的手术代码
      const isDuplicate = operations.some((o, i) => i !== currentIndex && o.oprnCode === item.code);
      if (isDuplicate) {
        message.warning(`手术代码 ${item.code} 已存在，请勿重复添加`);
        setIcdModalOpen(false);
        return;
      }
      
      // 手术：直接更新状态
      const newOperations = [...operations];
      newOperations[currentIndex] = { 
        ...newOperations[currentIndex], 
        oprnCode: item.code, 
        oprnName: item.desc 
      };
      
      // 如果是主手术，更新MainOperationCode，并确保只有一个主手术
      if (newOperations[currentIndex]?.mainFlag === '1') {
        form.setFieldValue('MainOperationCode', item.code);
        // 清除其他主手术标志
        newOperations.forEach((o, i) => {
          if (i !== currentIndex && o.mainFlag === '1') {
            newOperations[i] = { ...o, mainFlag: '0' };
          }
        });
      }
      setOperations(newOperations);
    }
    setIcdModalOpen(false);
    message.success(`已选择：${item.code} ${item.desc}`);
  };

  // 诊断列定义
  const diagnosisColumns = [
    {
      title: '主诊断',
      dataIndex: 'mainFlag',
      width: 80,
      render: (_: any, __: any, index: number) => (
        <Select
          value={diagnoses[index]?.mainFlag}
          onChange={(value) => updateDiagnosis(index, 'mainFlag', value)}
          style={{ width: '100%' }}
          options={[
            { value: 1, label: '是' },
            { value: 0, label: '否' }
          ]}
        />
      )
    },
    {
      title: '诊断序号',
      dataIndex: 'diagSn',
      width: 90,
      render: (_: any, __: any, index: number) => (
        <span>{diagnoses[index]?.diagSn}</span>
      )
    },
    {
      title: '诊断代码(ICD-10)',
      dataIndex: 'diagCode',
      render: (_: any, __: any, index: number) => (
        <Input
          placeholder="如：I21.0"
          value={diagnoses[index]?.diagCode}
          onChange={(e) => {
            const newValue = e.target.value;
            // 一次性更新：设置代码，清空名称
            let newDiagnoses = [...diagnoses];
            newDiagnoses[index] = { ...newDiagnoses[index], diagCode: newValue, diagName: '' };
            setDiagnoses(newDiagnoses);
            // 如果是主诊断，更新MainDiagnosisCode
            if (diagnoses[index]?.mainFlag === 1) {
              form.setFieldValue('MainDiagnosisCode', newValue);
            }
          }}
        />
      )
    },
    {
      title: '诊断名称',
      dataIndex: 'diagName',
      render: (_: any, __: any, index: number) => (
        <Input
          placeholder="如：急性心肌梗死"
          value={diagnoses[index]?.diagName}
          onChange={(e) => {
            const newValue = e.target.value;
            // 一次性更新：设置名称，清空代码
            let newDiagnoses = [...diagnoses];
            newDiagnoses[index] = { ...newDiagnoses[index], diagName: newValue, diagCode: '' };
            setDiagnoses(newDiagnoses);
            // 如果是主诊断，清空MainDiagnosisCode
            if (diagnoses[index]?.mainFlag === 1) {
              form.setFieldValue('MainDiagnosisCode', '');
            }
          }}
        />
      )
    },
    {
      title: '操作',
      width: 120,
      render: (_: any, record: any, index: number) => (
        <Space>
          <Button
            type="primary"
            size="small"
            onClick={() => openIcdSearchForDiagnosis(index)}
          >
            查询
          </Button>
          <Button
            type="text"
            danger
            icon={<DeleteOutlined />}
            onClick={() => removeDiagnosis(index)}
            disabled={diagnoses.length === 1}
          />
        </Space>
      )
    }
  ];

  // 手术列定义
  const operationColumns = [
    {
      title: '主手术',
      dataIndex: 'mainFlag',
      width: 80,
      render: (_: any, __: any, index: number) => (
        <Select
          value={operations[index]?.mainFlag}
          onChange={(value) => updateOperation(index, 'mainFlag', value)}
          style={{ width: '100%' }}
          options={yesNoOptions}
        />
      )
    },
    {
      title: '手术序号',
      dataIndex: 'oprnSn',
      width: 90,
      render: (_: any, __: any, index: number) => (
        <span>{operations[index]?.oprnSn}</span>
      )
    },
    {
      title: '手术代码(ICD-9-CM-3)',
      dataIndex: 'oprnCode',
      render: (_: any, __: any, index: number) => (
        <Input
          placeholder="如：51.23"
          value={operations[index]?.oprnCode}
          onChange={(e) => {
            const newValue = e.target.value;
            // 一次性更新：设置代码，清空名称
            const newOperations = [...operations];
            newOperations[index] = { ...newOperations[index], oprnCode: newValue, oprnName: '' };
            setOperations(newOperations);
            // 如果是主手术，更新MainOperationCode
            if (operations[index]?.mainFlag === '1') {
              form.setFieldValue('MainOperationCode', newValue);
            }
          }}
        />
      )
    },
    {
      title: '手术名称',
      dataIndex: 'oprnName',
      render: (_: any, __: any, index: number) => (
        <Input
          placeholder="如：冠状动脉造影术"
          value={operations[index]?.oprnName}
          onChange={(e) => {
            const newValue = e.target.value;
            // 一次性更新：设置名称，清空代码
            const newOperations = [...operations];
            newOperations[index] = { ...newOperations[index], oprnName: newValue, oprnCode: '' };
            setOperations(newOperations);
            // 如果是主手术，清空MainOperationCode
            if (operations[index]?.mainFlag === '1') {
              form.setFieldValue('MainOperationCode', '');
            }
          }}
        />
      )
    },
    {
      title: '操作',
      width: 120,
      render: (_: any, __: any, index: number) => (
        <Space>
          <Button
            type="primary"
            size="small"
            onClick={() => openIcdSearchForOperation(index)}
          >
            查询
          </Button>
          <Button
            type="text"
            danger
            icon={<DeleteOutlined />}
            onClick={() => removeOperation(index)}
          />
        </Space>
      )
    }
  ];

  // 医疗机构列定义
  const hospitalColumns = [
    {
      title: '医疗机构代码',
      dataIndex: 'code',
      render: (_: any, __: any, index: number) => (
        <Input
          placeholder="如：10001"
          value={hospitals[index]?.code}
          onChange={(e) => {
            const newValue = e.target.value;
            // 一次性更新：设置代码，清空名称
            const newHospitals = [...hospitals];
            newHospitals[index] = { ...newHospitals[index], code: newValue, descripts: '' };
            setHospitals(newHospitals);
          }}
        />
      )
    },
    {
      title: '医疗机构名称',
      dataIndex: 'descripts',
      render: (_: any, __: any, index: number) => (
        <Input
          placeholder="如：XX市人民医院"
          value={hospitals[index]?.descripts}
          onChange={(e) => {
            const newValue = e.target.value;
            // 一次性更新：设置名称，清空代码
            const newHospitals = [...hospitals];
            newHospitals[index] = { ...newHospitals[index], descripts: newValue, code: '' };
            setHospitals(newHospitals);
          }}
        />
      )
    },
    {
      title: '操作',
      width: 120,
      render: (_: any, __: any, index: number) => (
        <Space>
          <Button
            type="primary"
            size="small"
            onClick={() => openHospitalSearch(index)}
          >
            查询
          </Button>
          <Button
            type="text"
            danger
            icon={<DeleteOutlined />}
            onClick={() => removeHospital(index)}
          />
        </Space>
      )
    }
  ];

  return (
    <div style={{ width: '100%', boxSizing: 'border-box', padding: 16 }}>
      <Row gutter={24}>
        {/* 左侧：输入表单 */}
        <Col span={14}>
          <Card 
            title={
              <Space>
                <MedicineBoxOutlined />
                <span>DRG分组器</span>
              </Space>
            }
            style={{ 
              width: '100%',
              maxHeight: 'calc(100vh - 120px)',
              overflow: 'auto'
            }}
            bodyStyle={{ padding: '16px 24px' }}
          >
            {/* 提示信息 */}
            <Alert
              description={
                <div style={{ textAlign: 'left', lineHeight: 1.6, fontSize: 12 }}>
                  <Row gutter={8}>
                    <Col span={10}>
                      <div><Text strong>1.</Text>  主诊断必填且只有一个</div>
                      <div><Text strong>2.</Text> 手术或操作信息选填 </div>
                      
                    </Col>
                    <Col span={13}>
                     <div><Text strong>3.</Text> ICD编码版本均为国家医保局发布的医保版 </div>
                      <div><Text strong>4.</Text> 医疗机构算法信息需要在菜单"DRG核心算法配置维护"中提前维护</div>                      
                    </Col>
                  </Row>
                </div>
              }
              type="info"
              showIcon
              style={{ marginBottom: 12, padding: '8px 12px' }}
            />

            <Form
              form={form}
              layout="vertical"
              onFinish={handleSubmit}
              onKeyDown={(e) => {
                if (e.key === 'Enter') {
                  e.preventDefault();
                }
              }}
              initialValues={{
                Sex: '1',
                Age: 0,
                AgeGroupDays: 0,
                RespiratorTime: 0,
                ECMOFlag: '0',
                TransplantFlag: '0',
                MarrowTransplantFlag: '0',
                HIVFlag: '0',
                TraumaLevel: 0,
                HospitalDays: 1,
                DischargeType: '1', // 默认值：1-医嘱离院
                GroupYear: new Date().getFullYear(), // 默认当前年份
              }}
            >
          {/* 患者基本信息 */}
          <Card 
            title={
              <Space>
                <UserOutlined />
                <span>患者基本信息</span>
              </Space>
            } 
            size="small" 
            style={{ marginBottom: 16 }}
          >
            {/* 第一行：基础信息 */}
            <Row gutter={16}>
              <Col span={6}>
                <Form.Item name="Sex" label="性别" rules={[{ required: true }]}>
                  <Select options={sexOptions} />
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item name="Age" label="年龄(岁)" rules={[{ required: true }]}>
                  <InputNumber min={0} max={150} style={{ width: '100%' }} />
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item name="AgeGroupDays" label="新生儿天数">
                  <InputNumber 
                    min={0} 
                    max={28} 
                    placeholder="0-28天" 
                    style={{ width: '100%' }}
                    onChange={(value) => {
                      if (value && value > 0) {
                        form.setFieldValue('NewbornFlag', '1');
                      } else {
                        form.setFieldValue('NewbornFlag', '0');
                      }
                    }}
                  />
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item 
                  name="DischargeType" 
                  label="离院方式" 
                  rules={[{ required: true, message: '请选择离院方式' }]}
                >
                  <Select style={{ width: '100%' }} options={dischargeTypeOptions} />
                </Form.Item>
              </Col>
            </Row>

            {/* 第二行：科室和住院信息 */}
            <Row gutter={16}>
              <Col span={6}>
                <Form.Item name="TotalCost" label="当前医疗费用总额(元)">
                  <Input 
                    placeholder="请输入费用总额"
                  />
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item name="HospitalDays" label="住院天数">
                  <InputNumber 
                    min={1} 
                    style={{ width: '100%' }}
                  />
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item name="RespiratorTime" label="呼吸机时长(小时)">
                  <InputNumber 
                    min={0} 
                    max={9999} 
                    style={{ width: '100%' }}
                  />
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item name="TraumaLevel" label="创伤等级">
                  <InputNumber 
                    min={0} 
                    max={10} 
                    placeholder="≥2为严重创伤" 
                    style={{ width: '100%' }}
                  />
                </Form.Item>
              </Col>
            </Row>

            {/* 第三行：特殊治疗标志 */}
            <Row gutter={16}>
              <Col span={6}>
                <Form.Item name="ECMOFlag" label="ECMO标志">
                  <Select options={yesNoOptions} />
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item name="TransplantFlag" label="器官移植标志">
                  <Select options={yesNoOptions} />
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item name="MarrowTransplantFlag" label="骨髓移植标志">
                  <Select options={yesNoOptions} />
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item name="HIVFlag" label="HIV感染标志">
                  <Select options={yesNoOptions} />
                </Form.Item>
              </Col>
            </Row>

            {/* 第四行：参保省份、参保城市下拉框 */}
            <Row gutter={16}>
              <Col span={6}>
                <Form.Item name="Province" label="参保省份">
                  <Select
                    placeholder="请选择参保省份"
                    onChange={handleProvinceChange}
                    allowClear
                    loading={provinceLoading}
                    showSearch
                    optionFilterProp="children"
                    style={{ width: '100%' }}
                  >
                    {provinceList.map(item => (
                      <Option key={item.id} value={item.id}>{item.descripts}</Option>
                    ))}
                  </Select>
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item name="City" label="参保城市">
                  <Select
                    placeholder="请选择参保城市"
                    allowClear
                    loading={cityLoading}
                    showSearch
                    optionFilterProp="children"
                    disabled={!form.getFieldValue('Province')}
                    style={{ width: '100%' }}
                  >
                    {cityList.map(item => (
                      <Option key={item.id} value={item.id}>{item.descripts}</Option>
                    ))}
                  </Select>
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item 
                  name="GroupYear" 
                  label={
                    <Space size={4}>
                      <CalendarOutlined />
                      <span>分组方案年份</span>
                    </Space>
                  }
                >
                  <InputNumber 
                    min={2020} 
                    max={2099} 
                    placeholder="请输入年份"
                    style={{ width: '100%' }} 
                    precision={0}
                  />
                </Form.Item>
              </Col>
            </Row>

          </Card>

          {/* 诊断信息 */}
          <Card 
            title={
              <Space>
                <MedicineBoxOutlined />
                <span>诊断信息</span>
                <Text type="secondary">(主诊断必填，请使用ICD-10编码)</Text>
              </Space>
            } 
            size="small" 
            style={{ marginBottom: 16 }}
          >
            <Form.Item name="MainDiagnosisCode" hidden>
              <Input />
            </Form.Item>
            <Table
              dataSource={diagnoses}
              columns={diagnosisColumns}
              pagination={false}
              rowKey={(_, index) => `diag-${index}`}
              size="small"
            />
            <Button 
              type="dashed" 
              onClick={addDiagnosis} 
              icon={<PlusOutlined />}
              style={{ marginTop: 8, width: '100%' }}
            >
              添加诊断
            </Button>
          </Card>

          {/* 手术信息 */}
          <Card 
            title={
              <Space>
                <ScissorOutlined />
                <span>手术/操作信息</span>
                <Text type="secondary">(可选，请使用ICD-9-CM-3编码)</Text>
              </Space>
            } 
            size="small" 
            style={{ marginBottom: 16 }}
          >
            <Form.Item name="MainOperationCode" hidden>
              <Input />
            </Form.Item>
            <Table
              dataSource={operations}
              columns={operationColumns}
              pagination={false}
              rowKey={(_, index) => `oprn-${index}`}
              size="small"
            />
            <Button 
              type="dashed" 
              onClick={addOperation} 
              icon={<PlusOutlined />}
              style={{ marginTop: 8, width: '100%' }}
            >
              添加手术
            </Button>
          </Card>

          {/* 医疗机构信息 */}
          <Card 
            title={
              <Space>
                <BankOutlined />
                <span>医疗机构信息</span>
                <Text type="secondary">(可选，点击查询选择医疗机构)</Text>
              </Space>
            } 
            size="small" 
            style={{ marginBottom: 16 }}
          >
            <Table
              dataSource={hospitals}
              columns={hospitalColumns}
              pagination={false}
              rowKey={(_, index) => `hospital-${index}`}
              size="small"
            />
            <Button 
              type="dashed" 
              onClick={addHospital} 
              icon={<PlusOutlined />}
              style={{ marginTop: 8, width: '100%' }}
            >
              添加医疗机构
            </Button>
          </Card>

            {/* 提交按钮 */}
            <Form.Item>
              <Space>
                <Button 
                  type="primary" 
                  htmlType="submit" 
                  icon={<PlayCircleOutlined />}
                  loading={loading}
                  size="large"
                >
                  执行分组查询
                </Button>
                <Button 
                  icon={<ReloadOutlined />}
                  onClick={handleReset}
                  size="large"
                >
                  重置
                </Button>
              </Space>
            </Form.Item>
          </Form>
        </Card>
      </Col>

      {/* 右侧：分组结果 */}
      <Col span={10} style={{ position: 'sticky', top: 16, alignSelf: 'flex-start' }}>
        <Card 
          title="分组结果" 
          style={{ height: 'fit-content', minHeight: 200 }}
        >
          {result ? (
            <>
              {/* 分组状态总览 */}
              <Card 
                size="small"
                style={{ 
                  marginBottom: 16, 
                  backgroundColor: '#fafafa',
                  borderLeft: '4px solid #52c41a'
                }}
              >
                <Row gutter={16}>
                  <Col span={8}>
                    <div>
                      <Text type="secondary" style={{ display: 'block', marginBottom: 4, fontSize: 12 }}>分组状态</Text>
                      <Tag color={result.drg ? "success" : "warning"} style={{ fontSize: 14 }}>
                        {result.drg ? "分组成功" : "未分组"}
                      </Tag>
                    </div>
                  </Col>
                  <Col span={8}>
                    <div>
                      <Text type="secondary" style={{ display: 'block', marginBottom: 4, fontSize: 12 }}>合并症状态</Text>
                      <Tag color={result.ccFlag ? "red" : "green"} style={{ fontSize: 14 }}>
                        {result.ccFlag ? "有合并症" : "无合并症"}
                      </Tag>
                    </div>
                  </Col>
                  <Col span={8}>
                    <div>
                      <Text type="secondary" style={{ display: 'block', marginBottom: 4, fontSize: 12 }}>MDC编码</Text>
                      <Tag color="purple" style={{ fontSize: 12, whiteSpace: 'normal', height: 'auto' }}>
                        {result.mdc || '-'}{result.mdcDesc ? ` ${result.mdcDesc}` : ''}
                      </Tag>
                    </div>
                  </Col>
                </Row>
              </Card>

              {/* 折叠面板展示详细信息 */}
              <Collapse 
                defaultActiveKey={['drgInfo']} 
                size="small"
                style={{ backgroundColor: '#fff' }}
              >
                {/* DRG分组信息 */}
                <Collapse.Panel 
                  header={<Text strong>DRG分组信息 (共{result.drgInfo?.length || 0}个)</Text>} 
                  key="drgInfo"
                >
                  {result.drgInfo && result.drgInfo.length > 0 ? (
                    <div style={{
                      display: 'grid',
                      gridTemplateColumns: result.drgInfo.length === 1 ? '1fr' : 'repeat(auto-fill, minmax(260px, 1fr))',
                      gap: 12
                    }}>
                      {result.drgInfo.map((item, index) => (
                        <Card
                          key={index}
                          size="small"
                          style={{
                            backgroundColor: '#f0f9ff',
                            border: '1px solid #bae0ff',
                            width: '100%'
                          }}
                          bodyStyle={{ padding: '12px' }}
                        >
                          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                            <Text strong style={{ fontSize: 18, color: '#1890ff' }}>{item.code}</Text>
                            <Text strong style={{ fontSize: 14 }}>{item.desc}</Text>
                          </div>
                        </Card>
                      ))}
                    </div>
                  ) : (
                    <Alert message="未获得DRG分组信息" type="info" showIcon style={{ backgroundColor: '#fafafa' }} />
                  )}
                </Collapse.Panel>

                {/* 合并症信息 */}
                {result.complicationInfo && result.complicationInfo.length > 0 && (
                  <Collapse.Panel 
                    header={<Text strong>合并症信息 (共{result.complicationInfo.length}个)</Text>} 
                    key="complicationInfo"
                  >
                    <div style={{
                      display: 'grid',
                      gridTemplateColumns: result.complicationInfo.length === 1 ? '1fr' : 'repeat(auto-fill, minmax(260px, 1fr))',
                      gap: 10
                    }}>
                      {result.complicationInfo.map((item, index) => {
                        const isMCC = item.complication === 'MCC';
                        const isSingle = result.complicationInfo.length === 1;
                        return (
                          <Card
                            key={index}
                            size="small"
                            style={{
                              backgroundColor: isMCC ? '#fff2f0' : '#fff1f0',
                              border: isMCC ? '2px solid #ff4d4f' : '1px dashed #ffa39e',
                              width: '100%'
                            }}
                            bodyStyle={{ padding: '12px' }}
                          >
                            {isSingle ? (
                              // 只有一个时：一行显示所有信息
                              <div style={{ display: 'flex', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
                                <Text strong style={{ fontSize: 16, color: isMCC ? '#ff4d4f' : '#fa8c16' }}>
                                  {item.complication || '合并症'}
                                </Text>
                                <Text strong style={{ fontSize: 14, color: isMCC ? '#ff4d4f' : '#fa8c16' }}>
                                  {item.complicationDesc}
                                </Text>
                                <Text type="secondary" style={{ fontSize: 12 }}>|</Text>
                                <Text style={{ fontSize: 12 }}>{item.diagCode}</Text>
                                <Text style={{ fontSize: 12 }}>{item.diagName}</Text>
                              </div>
                            ) : (
                              // 多个时：两行显示
                              <>
                                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
                                  <Text strong style={{ fontSize: 16, color: isMCC ? '#ff4d4f' : '#fa8c16' }}>
                                    {item.complication || '合并症'}
                                  </Text>
                                  <Text strong style={{ fontSize: 14, color: isMCC ? '#ff4d4f' : '#fa8c16' }}>
                                    {item.complicationDesc}
                                  </Text>
                                </div>
                                <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                                  <Text type="secondary" style={{ fontSize: 12 }}>诊断:</Text>
                                  <Text style={{ fontSize: 12 }}>{item.diagCode}</Text>
                                  <Text style={{ fontSize: 12 }}>{item.diagName}</Text>
                                </div>
                              </>
                            )}
                          </Card>
                        );
                      })}
                    </div>
                  </Collapse.Panel>
                )}

                {/* 医疗机构算法信息 */}
                {result.hospAlgorithmInfo && result.hospAlgorithmInfo.length > 0 && (
                  <Collapse.Panel 
                    header={<Text strong>医疗机构算法信息 (共{result.hospAlgorithmInfo.length}家)</Text>} 
                    key="hospAlgorithmInfo"
                  >
                    <div style={{ 
                      display: 'grid', 
                      gridTemplateColumns: result.hospAlgorithmInfo.length === 1 ? '1fr' : 'repeat(auto-fill, minmax(280px, 1fr))',
                      justifyItems: result.hospAlgorithmInfo.length === 1 ? 'center' : 'stretch',
                      gap: 10 
                    }}>
                      {result.hospAlgorithmInfo.map((item, index) => (
                        <Card
                          key={index}
                          size="small"
                          style={{
                            backgroundColor: '#f6ffed',
                            border: '1px solid #b7eb8f'
                          }}
                          bodyStyle={{ padding: '12px' }}
                        >
                          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
                            <Tag color="green" style={{ fontSize: 13 }}>{item.drg}</Tag>
                            <Text type="secondary" style={{ fontSize: 11 }}>{item.hospName}</Text>
                          </div>
                          <Row gutter={[8, 4]}>
                            <Col span={12}>
                              <Text type="secondary" style={{ fontSize: 11 }}>基准点数: </Text>
                              <Text style={{ fontSize: 12 }}>{item.points || '-'}</Text>
                            </Col>
                            <Col span={12}>
                              <Text type="secondary" style={{ fontSize: 11 }}>预估标准: </Text>
                              <Text style={{ fontSize: 12 }}>{item.payStandard || '-'}</Text>
                            </Col>
                            <Col span={12}>
                              <Text type="secondary" style={{ fontSize: 11 }}>基准点值: </Text>
                              <Text style={{ fontSize: 12 }}>{item.pipValue || '-'}</Text>
                            </Col>
                            <Col span={12}>
                              <Text type="secondary" style={{ fontSize: 11 }}>差异系数: </Text>
                              <Text style={{ fontSize: 12 }}>{item.dgdov || '-'}</Text>
                            </Col>
                            <Col span={12}>
                              <Text type="secondary" style={{ fontSize: 11 }}>当前费用总额: </Text>
                              <Text style={{ fontSize: 12 }}>{item.totalCost !== undefined ? `¥${item.totalCost}` : '-'}</Text>
                            </Col>
                            <Col span={12}>
                              <Text type="secondary" style={{ fontSize: 11 }}>预估盈利: </Text>
                              <Text style={{ fontSize: 12, color: '#52c41a' }}>{item.preProfit !== undefined ? `¥${item.preProfit}` : '-'}</Text>
                            </Col>
                            <Col span={12}>
                              <Text type="secondary" style={{ fontSize: 11 }}>预估亏损: </Text>
                              <Text style={{ fontSize: 12, color: '#ff4d4f' }}>{item.preLoss !== undefined ? `¥${item.preLoss}` : '-'}</Text>
                            </Col>
                            <Col span={12}>
                              <Text type="secondary" style={{ fontSize: 11 }}>差异率: </Text>
                              <Text style={{ fontSize: 12 }}>{item.discrepancyRate !== undefined ? `${item.discrepancyRate}%` : '-'}</Text>
                            </Col>
                          </Row>
                        </Card>
                      ))}
                    </div>
                  </Collapse.Panel>
                )}
              </Collapse>
            </>
          ) : (
            <div style={{ 
              display: 'flex', 
              flexDirection: 'column', 
              alignItems: 'center', 
              justifyContent: 'center', 
              padding: '60px 20px',
              color: '#999'
            }}>
              <MedicineBoxOutlined style={{ fontSize: 48, marginBottom: 16, color: '#d9d9d9' }} />
              <Text style={{ fontSize: 14 }}>暂无分组结果</Text>
              <Text type="secondary" style={{ fontSize: 12, marginTop: 8 }}>请在左侧填写信息后点击"执行分组查询"</Text>
            </div>
          )}
        </Card>
      </Col>
    </Row>

    {/* ICD编码查询弹窗 */}
    <Modal
        title={icdQueryType === 'diagnosis' ? '查询ICD-10诊断编码 (02010022)' : '查询ICD-9手术编码 (02010022)'}
        open={icdModalOpen}
        onCancel={() => setIcdModalOpen(false)}
        footer={null}
        width={700}
      >
        <List
          bordered
          loading={icdLoading}
          dataSource={icdResults}
          renderItem={(item) => (
            <List.Item
              onDoubleClick={() => selectIcd(item)}
              style={{ cursor: 'pointer' }}
            >
              <List.Item.Meta
                title={<Space><Tag color="blue">{item.code}</Tag><span>{item.desc}</span></Space>}
                description={`省: ${item.provinceDesc || '-'} | 市: ${item.cityDesc || '-'} | 状态: ${item.statusDesc || '-'}`}
              />
            </List.Item>
          )}
          locale={{ emptyText: '双击选中查询结果' }}
        />
      </Modal>

    {/* 医疗机构查询弹窗 */}
    <Modal
        title="查询医疗机构 (01050103)"
        open={hospitalModalOpen}
        onCancel={() => setHospitalModalOpen(false)}
        footer={null}
        width={700}
      >
        <List
          bordered
          loading={hospitalLoading}
          dataSource={hospitalResults}
          renderItem={(item: HospitalItem) => (
            <List.Item
              onDoubleClick={() => selectHospital(item)}
              style={{ cursor: 'pointer' }}
            >
              <List.Item.Meta
                title={<Space><Tag color="green">{item.organizationCode || item.code}</Tag><span>{item.descripts}</span></Space>}
                description={
                  <span>
                    类型: {item.typeDesc || '-'} | 
                    等级: {item.gradeDesc || '-'} | 
                    性质: {item.natureDesc || '-'} | 
                    地区: {item.proDesc || ''}{item.cityDesc || ''}{item.areaDesc || ''} | 
                    状态: {item.active === 'Y' ? '启用' : '停用'}
                  </span>
                }
              />
            </List.Item>
          )}
          locale={{ emptyText: hospitalLoading ? '加载中...' : '暂无数据' }}
        />
      </Modal>

    </div>
  );
};

export default DRGCustomQuery;
