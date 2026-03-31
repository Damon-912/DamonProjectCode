/*
 * Create:      柿子
 * CreateDate:  2026/01/23
 * Describe：   病案首页
 * */
import React, { useEffect, useState, forwardRef, useImperativeHandle } from 'react';
import { Modal, Spin, Row, Col } from 'antd';
import { staticSelectData } from '../js/staticSelectData';
import '../style/index.less';

const MedicalRecordFrontPage = (props, ref) => {
    const userData = React.$getUserData();
    const [visible, setVisible] = useState(false);
    const [spinLoading, setSpinLoading] = useState(false);
    const [propParams, setPropParams] = useState({});

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
    
    const { width, title } = props;

    return (
        <div>
            <Modal
                open={visible}
                width={width || '46vw'}
                title={title || '病案首页预览'}
                footer={null}
                onCancel={() => modifyVisible(false)}
            >
                <Spin tip="加载中..." spinning={spinLoading}>
                    <div className="medical-record-front-page" style={{ maxHeight: '76vh', overflow: 'auto' }}>
                        <table border="1" className="emr-table">
                            <colgroup>
                                {/* 定义18列，每列宽度相等 */}
                                {Array.from({ length: 24 }).map((_, i) => (
                                    <col key={i} />
                                ))}
                            </colgroup>
                            <tbody>
                                {/* 医疗机构信息 */}
                                <tr>
                                    <td colSpan="24">
                                        <span className="emr-label">医疗机构</span>
                                        <span style={{ marginRight: '24px' }}>{propParams?.hospitalName || propParams?.hospDesc || userData?.hospDesc || ''}</span>
                                        （ <span className="emr-label">组织机构代码：</span>{propParams?.medinsOrgcode || propParams?.medins_org_code || ''} ）
                                    </td>
                                </tr>

                                {/* 标题栏 */}
                                <tr>
                                    <td colSpan="24" style={{ padding: '12px 0' }}>
                                        <Row>
                                            <Col span={7}>
                                                <div>
                                                    <span className="emr-label">医疗付费方式：</span>
                                                    {propParams?.paymentMethod || ''}
                                                </div>
                                            </Col>
                                            <Col span={10} style={{ textAlign: 'center' }}>
                                                <h3 style={{ margin: '0' }}>住院病案首页</h3>
                                            </Col>
                                            <Col span={7}>
                                                <div>{propParams?.dischargeDate || ''}</div>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={7}>
                                                <div>
                                                    <span className="emr-label">健康卡号：</span>
                                                    {propParams?.psnNo || propParams?.psn_no || ''}
                                                </div>
                                            </Col>
                                            <Col span={10} style={{ textAlign: 'center' }}>
                                                <div>第 {propParams?.patnIptCnt || propParams?.patn_ipt_cnt || ''}次住院</div>
                                            </Col>
                                            <Col span={7}>
                                                <div>
                                                    <span className="emr-label">病案号：</span>
                                                    {propParams?.medcas_no || propParams?.medcasNo || ''}
                                                </div>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>

                                {/* 患者基本信息 */}
                                <tr className="emr-pat-info">
                                    <td colSpan="24">
                                        <Row>
                                            <Col span={5}>
                                                <span className="emr-label">姓名</span>
                                                <span className="emr-value">
                                                    {propParams?.psn_name || propParams?.psnName || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">性别</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.gend || ''}
                                                </span>
                                                {renderMap(staticSelectData?.gender || [])}
                                            </Col>
                                            <Col span={7}>
                                                <span className="emr-label">出生日期</span>
                                                <span className="emr-value">{propParams?.brdy || ''}</span>
                                            </Col>
                                            <Col span={7}>
                                                <span className="emr-label">年龄</span>
                                                <span className="emr-value">{propParams?.age || ''}</span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={5}>
                                                <span className="emr-label">国籍</span>
                                                <span className="emr-value">{propParams?.ntlyName || ''}</span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">民族</span>
                                                <span className="emr-value">{propParams?.naty_name || propParams?.naty || ''}</span>
                                            </Col>
                                            <Col span={7}>
                                                <span className="emr-label">新生儿出生体重</span>
                                                <span className="emr-value emr-value-date textCenter">
                                                    {propParams?.nwb_bir_wt || '-'}
                                                </span>克
                                            </Col>
                                            <Col span={7}>
                                                <span className="emr-label">新生儿入院体重</span>
                                                <span className="emr-value emr-value-date textCenter">
                                                    {propParams?.nwb_adm_wt || '-'}
                                                </span>克
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={17}>
                                                <span className="emr-label">出生地址</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 112px)' }}>
                                                    {propParams?.birplc || ''}
                                                </span>
                                            </Col>
                                            <Col span={7}>
                                                <span className="emr-label">籍贯</span>
                                                <span className="emr-value">
                                                    {propParams?.napl || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={9}>
                                                <span className="emr-label">证件号码</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 86px)' }}>
                                                    {propParams?.certno || ''}
                                                </span>
                                            </Col>
                                            <Col span={4}>
                                                <span className="emr-label">职业</span>
                                                <span className="emr-value">
                                                    {propParams?.prfs || ''}
                                                </span>
                                            </Col>
                                            <Col span={11}>
                                                <span className="emr-label">婚姻</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.mrg_stas || ''}
                                                </span>
                                                {renderMap(staticSelectData?.marital || [])}
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={14}>
                                                <span className="emr-label">现住址</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 68px)', fontSize: '12px' }}>
                                                    {propParams?.currAddr || propParams?.curr_addr || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">电话</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 58px)' }}>
                                                    {propParams?.psnTel || propParams?.psn_tel || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">邮编</span>
                                                <span className="emr-value">
                                                    {propParams?.currAddrPoscode || propParams?.curr_addr_poscode || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={19}>
                                                <span className="emr-label">户口地址</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 86px)', fontSize: '12px' }}>
                                                    {propParams?.resdAddr || propParams?.resd_addr || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">邮编</span>
                                                <span className="emr-value">
                                                    {propParams?.resdAddrPoscode || propParams?.resd_addr_poscode || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={14}>
                                                <span className="emr-label">工作单位</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 86px)', fontSize: '12px' }}>
                                                    {propParams?.emprAddr || propParams?.empr_addr || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">单位电话</span>
                                                <span className="emr-value">
                                                    {propParams?.emprTel || propParams?.empr_tel || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">邮编</span>
                                                <span className="emr-value">
                                                    {propParams?.emprPoscode || propParams?.empr_poscode || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={5}>
                                                <span className="emr-label">联系人姓名</span>
                                                <span className="emr-value">
                                                    {propParams?.conerName || propParams?.coner_name || ''}
                                                </span>
                                            </Col>
                                            <Col span={4}>
                                                <span className="emr-label">关系</span>
                                                <span className="emr-value">
                                                    {propParams?.conerRltsCode || propParams?.coner_rlts_code || ''}
                                                </span>
                                            </Col>
                                            <Col span={10}>
                                                <span className="emr-label">地址</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 58px)', fontSize: '12px' }}>
                                                    {propParams?.conerAddr || propParams?.coner_addr || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">电话</span>
                                                <span className="emr-value">
                                                    {propParams?.conerTel || propParams?.coner_tel || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={24}>
                                                <span className="emr-label">入院途径</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.admWayName || propParams?.adm_way_name || ''}
                                                </span>
                                                {renderMap(staticSelectData?.admissionRoute || [], '.', '24px', 'N')}
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={10}>
                                                <span className="emr-label">入院时间</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 112px)' }}>
                                                    {propParams?.admDate || propParams?.adm_date || ''}
                                                </span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label">入院科室</span>
                                                <span className="emr-value">
                                                    {propParams?.admCaty || propParams?.adm_caty || ''}
                                                </span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label">病房</span>
                                                <span className="emr-value">
                                                    {propParams?.admWard || propParams?.adm_ward || ''}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={10}>
                                                {/* 取值异常 */}
                                                <span className="emr-label">转科</span>
                                                1.
                                                <span className="emr-value emr-value-date textCenter">{propParams?.transferDepartment1 || '-'}</span> 年
                                                <span className="emr-value emr-value-date textCenter">{propParams?.transferYear1 || '-'}</span> 月
                                                <span className="emr-value emr-value-date textCenter">{propParams?.transferMonth1 || '-'}</span> 日
                                                <span className="emr-value emr-value-date textCenter">{propParams?.transferDay1 || '-'}</span> 时转
                                                <span className="emr-value emr-value-date textCenter">{propParams?.transferToDepartment1 || '-'}</span>
                                            </Col>
                                            <Col span={10}>
                                                2.
                                                <span className="emr-value emr-value-date textCenter">{propParams?.transferDepartment2 || '-'}</span> 年
                                                <span className="emr-value emr-value-date textCenter">{propParams?.transferYear2 || '-'}</span> 月
                                                <span className="emr-value emr-value-date textCenter">{propParams?.transferMonth2 || '-'}</span> 日
                                                <span className="emr-value emr-value-date textCenter">{propParams?.transferDay2 || '-'}</span> 时转
                                                <span className="emr-value emr-value-date textCenter">{propParams?.transferToDepartment2 || '-'}</span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={8}>
                                                <span className="emr-label">出院时间</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 112px)' }}>
                                                    {propParams?.dscgDate || propParams?.dscg_date || ''}
                                                </span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label">出院科别</span>
                                                <span className="emr-value">
                                                    {propParams?.dscgCaty || propParams?.dscg_caty || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">病房</span>
                                                <span className="emr-value">
                                                    {propParams?.dscgWard || propParams?.dscg_ward || ''}
                                                </span>
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">实际住院</span>
                                                <span
                                                    className="emr-value"
                                                    style={{ width: 'calc(100% - 100px)', marginRight: '8px' }}
                                                >
                                                    {propParams?.iptDays || propParams?.ipt_days || ''}
                                                </span>
                                                天
                                            </Col>
                                        </Row>
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={10}>
                                                {/* 取值异常 */}
                                                <span className="emr-label">门（急）诊诊断</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 140px)' }}>{propParams?.outpatientDiagnosis || ''}</span>
                                            </Col>
                                            <Col span={8}>
                                                {/* 取值异常 */}
                                                <span className="emr-label">门（急）诊诊断编码</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 166px)' }}>{propParams?.outpatientDiagnosisCode || ''}</span>
                                            </Col>
                                            <Col span={6}>
                                                {/* 取值异常 */}
                                                <span className="emr-label">门（急）诊医师</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 126px)' }}>{propParams?.outpatientDoctor || ''}</span>
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

                                {handleEmrTableDataProcessing(propParams?.dise_info || propParams?.diseInfo || [], 11).map((item, index) => {
                                    return (
                                        <tr key={index}>
                                            <td colSpan="8">{index === 0 ? '主要诊断：' : (index === 1 ? '其他诊断：' : '')}
                                                {/* 出院诊断 */}
                                                {item?.diagName || item?.diag_name || ''}</td>
                                            <td colSpan="8">
                                                {/* 疾病编码 */}
                                                {item?.diagCode || item?.diag_code || ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 入院病情 */}
                                                {(item?.admCond || item?.adm_cond || '') == '1' ? '√' : ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 临床不确定 */}
                                                {(item?.admCond || item?.adm_cond || '') == '2' ? '√' : ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 情况不明 */}
                                                {(item?.admCond || item?.adm_cond || '') == '3' ? '√' : ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 无 */}
                                                {(item?.admCond || item?.adm_cond || '') == '4' ? '√' : ''}
                                            </td>
                                        </tr>
                                    )
                                })}

                                {/* 病例分型和临床路径 */}
                                <tr className="emr-other-info">
                                    <td colSpan="24">
                                        <Row>
                                            <Col span={10}>
                                                {/* 取值异常 */}
                                                <span className="emr-label">病例分型</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.caseType || ''}
                                                </span>
                                                {renderMap(staticSelectData?.caseType || [], 'N', '10px', 'N')}
                                            </Col>
                                            <Col span={7}>
                                                {/* 取值异常 */}
                                                <span className="emr-label">临床路径病例</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.clinicalPathwayFlag || ''}
                                                </span>
                                                {renderMap(staticSelectData?.clinicalPathway || [])}
                                            </Col>
                                            <Col span={3}>
                                                抢救
                                                <span className="emr-value textCenter" style={{ width: '24px' }}>
                                                    {propParams?.rescCnt || propParams?.resc_cnt || '0'}
                                                </span>
                                                次
                                            </Col>
                                            <Col span={3}>
                                                成功
                                                <span className="emr-value textCenter" style={{ width: '24px' }}>
                                                    {propParams?.rescSuccCnt || propParams?.resc_succ_cnt || '0'}
                                                </span>
                                                次
                                            </Col>
                                        </Row>
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={14}>
                                                <span className="emr-label">损伤、中毒的外部原因：</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 186px)' }}>
                                                    {propParams?.damgIntxExtRea || propParams?.damg_intx_ext_rea || '无'}
                                                </span>
                                            </Col>
                                            <Col span={10}>
                                                <span className="emr-label">损伤、中毒外部原因编码：</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 186px)' }}>
                                                    {propParams?.damgIntxExtReaDisecode || propParams?.damg_intx_ext_rea_disecode || '-'}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>

                                <tr>
                                    <td colSpan="24">
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={9}>
                                                {/* 取值异常 */}
                                                <span className="emr-label">病理诊断名称：</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 136px)' }}>
                                                    {propParams?.pathologicalDiagnosis || '-'}
                                                </span>
                                            </Col>
                                            <Col span={8}>
                                                {/* 取值异常 */}
                                                <span className="emr-label">病理诊断编码：</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 136px)' }}>
                                                    {propParams?.pathologicalDiagnosisCode || '-'}
                                                </span>
                                            </Col>
                                            <Col span={7}>
                                                <span className="emr-label">病理号：</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 86px)' }}>
                                                    {propParams?.palgNo || propParams?.palg_no || '-'}
                                                </span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>

                                <tr className="emr-other-info">
                                    <td colSpan={24}>
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span="5">
                                                <span className="emr-label">药物过敏</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.drugDicmFlag || propParams?.drug_dicm_flag || ''}
                                                </span>
                                                {renderMap(staticSelectData?.drugAllergy || [])}
                                            </Col>
                                            <Col span="13">
                                                ，过敏药物
                                                <span className="emr-value" style={{ width: 'calc(100% - 108px)' }}>
                                                    {propParams?.dicmDrugName || propParams?.dicm_drug_name || ''}
                                                </span>
                                            </Col>
                                            <Col span="6">
                                                <span className="emr-label">死亡患者尸检</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.dieAutpFlag || propParams?.die_autp_flag || ''}
                                                </span>
                                                {renderMap(staticSelectData?.autopsy || [])}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>

                                <tr className="emr-other-info">
                                    <td colSpan={24}>
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span="13">
                                                <span className="emr-label">ABO血型</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.aboCode || propParams?.abo_code || ''}
                                                </span>
                                                {renderMap(staticSelectData?.bloodType || [])}
                                            </Col>
                                            <Col span="11">
                                                <span className="emr-label">Rh血型</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.rhCode || propParams?.rh_code || ''}
                                                </span>
                                                {renderMap(staticSelectData?.rhBloodType || [])}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>

                                {/* 医师信息 */}
                                <tr className="emr-other-info">
                                    <td colSpan="24">
                                        <Row>
                                            <Col span={6}>
                                                <span className="emr-label">科主任</span>
                                                <span>{propParams?.deptdrtName || propParams?.deptdrt_name || ''}</span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label">主任（副主任）医师</span>
                                                <span>{propParams?.chfdr_Name || ''}</span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label">主治医师</span>
                                                <span>{propParams?.atddrName || propParams?.atddr_name || ''}</span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label">住院医师</span>
                                                <span>{propParams?.iptDrName || propParams?.ipt_dr_name || ''}</span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={6}>
                                                <span className="emr-label">责任护士</span>
                                                <span>{propParams?.respNursName || propParams?.resp_nurs_name || ''}</span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label">进修医师</span>
                                                <span>{propParams?.trainDrName || propParams?.train_dr_name || ''}</span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label">实习医师</span>
                                                <span>{propParams?.intnDrName || propParams?.intn_dr_name || ''}</span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label">编码员</span>
                                                <span>{propParams?.codrName || propParams?.codr_name || ''}</span>
                                            </Col>
                                        </Row>
                                        <Row>
                                            <Col span={7}>
                                                <span className="emr-label">病案质量</span>
                                                <span style={{ marginRight: '12px' }}>{propParams?.medcas_qlt_code || ''}</span>
                                                {renderMap(staticSelectData?.recordQuality || [])}
                                            </Col>
                                            <Col span={5}>
                                                <span className="emr-label">质控医师</span>
                                                <span>{propParams?.qltctrlDrName || propParams?.qltctrl_dr_name || ''}</span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label">质控护士</span>
                                                <span>{propParams?.qltctrlNursName || propParams?.qltctrl_nurs_name || ''}</span>
                                            </Col>
                                            <Col span={6}>
                                                <span className="emr-label">日期</span>
                                                {propParams?.medcasQltDate || propParams?.medcas_qlt_date || ''}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>

                                {/* 手术信息 */}
                                <tr>
                                    <td rowSpan="2" colSpan="2" className="textCenter">手术及操作日期</td>
                                    <td rowSpan="2" colSpan="2" className="textCenter">手术及操作编码</td>
                                    <td rowSpan="2" colSpan="6" className="textCenter">手术及操作名称</td>
                                    <td rowSpan="2" colSpan="1" className="textCenter">手术级别</td>
                                    <td colSpan="6" className="textCenter">手术及操作医师</td>
                                    <td rowSpan="2" colSpan="2" className="textCenter">切口愈合等级</td>
                                    <td rowSpan="2" colSpan="1" className="textCenter">择期手术</td>
                                    <td rowSpan="2" colSpan="2" className="textCenter">麻醉方式</td>
                                    <td rowSpan="2" colSpan="2" className="textCenter">麻醉医师</td>
                                </tr>
                                <tr>
                                    <td colSpan="2" className="textCenter">术者</td>
                                    <td colSpan="2" className="textCenter">I助</td>
                                    <td colSpan="2" className="textCenter">II助</td>
                                </tr>

                                {handleEmrTableDataProcessing(propParams?.oprn_info || propParams?.oprnInfo || [], 4).map((item, index) => {
                                    return (
                                        <tr key={index}>
                                            <td colSpan="2" className="textCenter">
                                                {/* 手术及操作日期 */}
                                                {item?.oprnOprtDate || item?.oprn_oprt_date || ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 手术及操作编码 */}
                                                {item?.oprnOprtCode || item?.oprn_oprt_code || ''}
                                            </td>
                                            <td colSpan="6" className="textCenter">
                                                {/* 手术及操作名称 */}
                                                {item?.oprnOprtName || item?.oprn_oprt_name || ''}
                                            </td>
                                            <td colSpan="1" className="textCenter">
                                                {/* 手术级别 */}
                                                {item?.oprnLvName || item?.oprn_lv_name || ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 术者 */}
                                                {item?.operName || item?.oper_name || ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 1助 */}
                                                {item?.asit1Name || item?.asit_1_name || ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 2助 */}
                                                {item?.asitName2 || item?.asit_name2 || ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 切口愈合等级 */}
                                                {item?.sincHealLv || item?.sinc_heal_lv || ''}
                                            </td>
                                            <td colSpan="1" className="textCenter">
                                                {/* 择期手术 */}
                                                {item?.oprnElectiveSurgery || item?.oprn_elective_surgery || ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 麻醉方式 */}
                                                {item?.anstMtdName || item?.anst_mtd_name || ''}
                                            </td>
                                            <td colSpan="2" className="textCenter">
                                                {/* 麻醉医师 */}
                                                {item?.anstDrName || item?.anst_dr_name || ''}
                                            </td>
                                        </tr>
                                    )
                                })}

                                {/* 离院方式和再住院计划 */}
                                <tr className="emr-other-info">
                                    <td colSpan="24">
                                        <Row>
                                            <Col span={7}>
                                                <span>离院方式</span>
                                                <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                                    {propParams?.dscgWay || propParams?.dscg_way || ''}
                                                </span>
                                                <span>1.医嘱离院</span>
                                            </Col>
                                            <Col span={15}>
                                                <span>2.医嘱转院，拟接收医疗机构名称：</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 236px)' }}>
                                                    {propParams?.acpMedinsName || propParams?.acp_medins_name || '-'}
                                                </span>
                                            </Col>
                                        </Row>
                                        <Row style={{ marginBottom: '4px' }}>
                                            <Col span={17}>
                                                {/* 取值异常 */}
                                                <span>3.医嘱转社区卫生服务机构/乡镇卫生院，拟接收医疗机构名称：</span>
                                                <span className="emr-value" style={{ width: 'calc(100% - 410px)' }}>
                                                    {propParams?.transferCommunityName || '-'}
                                                </span>
                                            </Col>
                                            <Col span={7}>
                                                <span style={{ marginRight: '24px' }}>4.非医嘱离院</span>
                                                <span style={{ marginRight: '24px' }}>5.死亡</span>
                                                <span>9.其他</span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>

                                <tr>
                                    <td colSpan="24">
                                        是否有出院31天内再住院计划
                                        <span className="emr-value" style={{ width: '24px', marginRight: '12px' }}>
                                            {propParams?.dscg31daysRinpFlag || propParams?.dscg_31days_rinp_flag || ''}
                                        </span>
                                        {renderMap(staticSelectData?.readmissionPlan || [])}
                                        ，目的：
                                        <span className="emr-value" style={{ width: 'calc(100% - 410px)' }}>
                                            {propParams?.dscg31daysRinpPup || propParams?.dscg_31days_rinp_pup || ''}
                                        </span>
                                    </td>
                                </tr>

                                <tr>
                                    <td colSpan="24">
                                        <span style={{ marginRight: '36px' }}>
                                            颅脑损伤患者昏迷时间：入院前/天/小时/分钟
                                        </span>
                                        <span>
                                            入院后/天/小时/分钟
                                        </span>
                                    </td>
                                </tr>

                                {/* 住院费用 */}
                                <tr>
                                    <td colSpan="24">
                                        住院费用（元）：总费用
                                        {propParams?.medfeeSumamt || propParams?.medfee_sumamt || '0.00'}
                                        （ 自付金额：
                                        {propParams?.selfpayAmt || propParams?.selfpay_amt || '0.00'} ）
                                    </td>
                                </tr>
                                <tr>
                                    <td rowSpan="2" colSpan="5" className="textCenter">1.综合医疗服务类</td>
                                    <td colSpan="19">
                                        <Row>
                                            <Col span={14}>
                                                （1）一般医疗服务费：{propParams?.ordnMedServfee || propParams?.ordn_med_servfee || '0.00'}
                                            </Col>
                                            <Col span={10}>
                                                （2）一般治疗操作费：{propParams?.ordnTrtOprtFee || propParams?.ordn_trt_oprt_fee || '0.00'}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="19">
                                        <Row>
                                            <Col span={14}>
                                                （3）护理费：{propParams?.nursFee || propParams?.nurs_fee || '0.00'}
                                            </Col>
                                            <Col span={10}>
                                                （4）其他费用：{propParams?.comMedServOthFee || propParams?.com_med_serv_oth_fee || '0.00'}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td rowSpan="2" colSpan="5" className="textCenter">2.诊断类</td>
                                    <td colSpan="19">
                                        <Row>
                                            <Col span={14}>
                                                （5）病理诊断费：{propParams?.palgDiagFee || propParams?.palg_diag_fee || '0.00'}
                                            </Col>
                                            <Col span={10}>
                                                （6）实验室诊断费：{propParams?.labDiagFee || propParams?.lab_diag_fee || '0.00'}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="19">
                                        <Row>
                                            <Col span={14}>
                                                （7）影像学诊断费：{propParams?.rdhyDiagFee || propParams?.rdhy_diag_fee || '0.00'}
                                            </Col>
                                            <Col span={10}>
                                                （8）临床诊断项目费：{propParams?.clncDiseFee || propParams?.clnc_dise_fee || '0.00'}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td rowSpan="2" colSpan="5" className="textCenter">3.治疗类</td>
                                    <td colSpan="19">
                                        （9）非手术治疗项目费：
                                        <span style={{ marginRight: '36px' }}>
                                            {propParams?.nsrgtrtItemFee || propParams?.nsrgtrt_item_fee || '0.00'}
                                        </span>
                                        （临床物理治疗费：{propParams?.clncPhysTrtFee || propParams?.clnc_phys_trt_fee || '0.00'}）
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="19">
                                        （10）手术治疗费：
                                        <span style={{ marginRight: '36px' }}>{propParams?.rgtrtTrtFee || propParams?.rgtrt_trt_fee || '0.00'}</span>
                                        （ 麻醉费：{propParams?.anstFee || propParams?.anst_fee || '0.00'} 手术费：{propParams?.rgtrtFee || propParams?.rgtrt_fee || '0.00'} ）
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="5" className="textCenter">4.康复类</td>
                                    <td colSpan="19">（11）康复费：{propParams?.rhabFee || propParams?.rhabFee || '0.00'}</td>
                                </tr>
                                <tr>
                                    <td colSpan="5" className="textCenter">5.中医类</td>
                                    <td colSpan="19">（12）中医治疗费：{propParams?.tcmTrtFee || propParams?.tcm_trt_fee || '0.00'}</td>
                                </tr>
                                <tr>
                                    <td colSpan="5" className="textCenter">6.西药类</td>
                                    <td colSpan="19">
                                        （13）西药费：
                                        <span style={{ marginRight: '36px' }}>{propParams?.wmFee || propParams?.wm_fee || '0.00'} </span>
                                        （ 抗菌药物费用：{propParams?.abtlMednFee || '0.00'} ）
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="5" className="textCenter">7.中药类</td>
                                    <td colSpan="19">
                                        <Row>
                                            <Col span={14}>
                                                （14）中成药费：{propParams?.tcmpatFee || propParams?.tcmpat_fee || '0.00'}
                                            </Col>
                                            <Col span={10}>
                                                （15）中草药费：{propParams?.tcmherbFee || propParams?.tcmherb_fee || '0.00'}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td rowSpan="2" colSpan="5" className="textCenter">8.血液和血液制品类</td>
                                    <td colSpan="19">
                                        <Row>
                                            <Col span={14}>
                                                （16）血费：
                                                <span style={{ marginRight: '36px' }}>{propParams?.bloFee || propParams?.blo_fee || '0.00'}</span>
                                                （17）白蛋白类制品费：
                                                <span style={{ marginRight: '36px' }}>{propParams?.albuFee || propParams?.albu_fee || '0.00'}</span>
                                            </Col>
                                            <Col span={10}>
                                                （18）球蛋白类制品费：
                                                <span style={{ marginRight: '36px' }}>{propParams?.glonFee || propParams?.glon_fee || '0.00'}</span>
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="19">
                                        <Row>
                                            <Col span={14}>
                                                （19）凝血因子类制品费：{propParams?.clotfacFee || propParams?.clotfac_fee || '0.00'}
                                            </Col>
                                            <Col span={10}>
                                                （20）细胞因子类制品费：{propParams?.cykiFee || propParams?.cyki_fee || '0.00'}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td rowSpan="2" colSpan="5" className="textCenter">9.耗材类</td>
                                    <td colSpan="19">
                                        <Row>
                                            <Col span={14}>
                                                （21）检查用一次性医用材料费：{propParams?.examDspoMatlFee || propParams?.exam_dspo_matl_fee || '0.00'}
                                            </Col>
                                            <Col span={10}>
                                                （22）治疗用一次性医用材料费：{propParams?.trtDspoMatlFee || propParams?.trt_dspo_matl_fee || '0.00'}
                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="19">
                                        <Row>
                                            <Col span={14}>
                                                （23）手术用一次性医用材料费：{propParams?.oprnDspoMatlFee || propParams?.oprn_dspo_matl_fee || '0.00'}
                                            </Col>
                                            <Col span={10}>

                                            </Col>
                                        </Row>
                                    </td>
                                </tr>
                                <tr>
                                    <td colSpan="5" className="textCenter">10.其他类</td>
                                    <td colSpan="19">（24）其他费用：{propParams?.othFee || propParams?.oth_fee || '0.00'}</td>
                                </tr>

                                {/* 说明 */}
                                <tr>
                                    <td colSpan="24">
                                        说明：（一）医疗付款方式：
                                        {renderMap(staticSelectData?.paymentMethod || [], '-', '36px', 'N')}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </Spin>
            </Modal>
        </div >
    )
};

export default forwardRef(MedicalRecordFrontPage);