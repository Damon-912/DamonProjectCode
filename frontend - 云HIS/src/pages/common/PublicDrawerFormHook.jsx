/*
 * Create:      柿子
 * CreateDate:  2024/05/17
 * Describe：   抽屉表单公共组件
 * */
import React, { useState, useEffect, forwardRef, useImperativeHandle, useRef } from 'react';
import { Row, Col, Drawer, Tabs, Button, Space } from 'antd';
import { LinkOutlined } from '@ant-design/icons';
import { Util } from '@tools';
import request from '@api';
import store from '@store';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import MenuAssociatedComponents from '@pages/systemMaintenance/component/MenuAssociatedComponents'; // 菜单关联组件
import './style/index.less';

// 关联tab，渲染tab组件
function TabsComponent(props) {
    let propLinkTabData = props?.linkTabData || [];
    const { documentHeight } = store.getState();
    const [activeKey, setActiveKey] = useState('1');
    const [formRefs, setFormRefs] = React.useState([]);
    const [linkTabData, setLinkTabData] = useState([]);
    const [activeRecord, setActiveRecord] = useState({});

    useEffect(() => {
        if (propLinkTabData && propLinkTabData.length > 0) {
            setFormRefs(propLinkTabData.map(() => React.createRef()));
            if (!(linkTabData && Array.isArray(linkTabData) && linkTabData.length > 0)) { // 去除不必要的修改
                setActiveKey(propLinkTabData[0]?.key || '');
                setActiveRecord(propLinkTabData[0]);
                setLinkTabData(propLinkTabData);
            }
        }
    }, [propLinkTabData]);

    const handleTabChange = (key) => {
        setActiveKey(key);
        let nActiveRecord = Util.returnDataCccordingToAttributes(linkTabData, key, 'key');
        setActiveRecord(nActiveRecord);
        props && 'onChange' in props && props.onChange(nActiveRecord);
    };

    const getTabsItem = (tabs) => {
        return tabs && Array.isArray(tabs) ? tabs.map((item, index) => {
            const DynamicComponent = item?.component || '';
            const currentKey = item?.id || item?.key || String(index + 1)
            return {
                key: currentKey,
                label: item?.label || item?.title || '',
                children: (
                    <div>
                        {item?.tabType === 'table' ? ( // 渲染表格
                            <PublicTablePagination
                                param={{
                                    page: item?.page || '',
                                    total: item?.total || '',
                                    loading: item?.loading || false,
                                    // 表头配置
                                    defaultPageSize: item?.defaultPageSize || 20,
                                    columns: item?.columns || [],
                                    x: item?.totalWidth || 0, // 表格的宽度
                                    y: documentHeight - 100 - (linkTabData && linkTabData.length > 1 ? 120 : 90),
                                    height: documentHeight - 100 - (linkTabData && linkTabData.length > 1 ? 90 : 50) + 'px',
                                    data: item?.tableData || [], // 表格数据
                                }}
                                compilePage={(page, pageSize) => handlePaginationChange(page, pageSize, item, index)}
                                onRow={(record) => handleRowClick(record, item, index)}
                                rowClassName={(record) => setRowClassName(record, item, index)}
                            />
                        ) : (item?.tabType === 'customRendering' ? ( // 自定义渲染
                            <DynamicComponent
                                {...(item?.params || {})} // 组件参数
                                tabKey={currentKey}
                                rowData={props?.rowData || {}}
                                selectData={props?.selectData || {}}
                                activeKey={activeKey}
                                activeRecord={activeRecord}
                            />
                        ) : (item?.tabType === 'baseInfo' ? (
                            props?.baseInfoDom || ''
                        ) : // 默认渲染表单
                            (<DynamicRenderingForm
                                rowData={item?.rowData || {}}
                                formData={item?.formData || []}
                                selectData={props?.selectData || {}}
                                formItemCol={item?.formItemCol || { labelCol: 24, wrapperCol: 24, col: 24 }}
                                ref={(formRefs && formRefs.length > index) ? formRefs[index] : null}
                            />
                            )))}
                    </div>
                )
            }
        }) : []
    };

    return (
        <Tabs items={getTabsItem(props?.linkTabData || [])} activeKey={activeKey} onChange={handleTabChange} />
    );
}

const PublicDrawerFormHook = (props, ref) => {
    let formRef = useRef(null);
    let selectComponentsRef = useRef(null);
    const propsRowData = props?.rowData || {};
    const linkDataFiled = props?.linkDataFiled || 'componentArr'; // 关联数据对应字段，栗：菜单管理 菜单关联组件保存修改及返回的字段【componentArr】
    const interfaceKey = props?.modalKey || Util.uuid();
    const { documentHeight } = store.getState();
    const [drawerWidth, setDrawerWidth] = useState('');
    const [visible, setVisible] = useState(false);
    const [httpFormData, setHttpFormData] = useState([]);
    const [linkData, setLinkData] = useState([]); // 关联数据
    const [linkTabData, setLinkTabData] = useState([]);
    const [okLoading, setLoading] = useState(false);

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible,
        getFieldsValue,
        resetFields,
        handleSave,
        modifyOkLoading: (loading) => setLoading(loading),
    }));

    // 修改弹窗状态
    const modifyVisible = (visible, isReset, pLinkTabData = [], otherData) => {
        setVisible(visible);
        if (visible) {
            setLinkTabData(pLinkTabData);
            getFormData();
            // 其他信息设置
            if (otherData && 'width' in otherData) {
                setDrawerWidth(otherData?.width || '');
            };
            if (otherData?.clearDrawerWidthFlag === 'Y') { // 如果根据tab修改宽度后直接关闭弹窗，宽度没有修改回去会有问题
                setDrawerWidth('');
            };
        }
        okLoading && setLoading(false);
        isReset === 'Y' && resetFields();
    };

    useEffect(() => {
        if (visible && props?.componentsSelectFlag === 'Y') {
            let linkData = propsRowData && linkDataFiled in propsRowData && Array.isArray(propsRowData[linkDataFiled]) ? propsRowData[linkDataFiled] : [];
            setLinkData(linkData);
        }
    }, [propsRowData]);

    // 重置
    const resetFields = () => {
        formRef && formRef.current && formRef.current.resetFields();
    };

    // 获取表单数据
    const getFormData = async () => {
        try {
            if (currentFormData && Array.isArray(currentFormData) && currentFormData.length > 0) return;
            const { componentName, componentInfo = {} } = props;
            let nComponentInfo = componentInfo;
            if (!(nComponentInfo?.componentCode || '')) { // 如果根据菜单代码没有取到组件相关信息由弹窗自己获取
                if (!componentName) return;
                const res = await request.getComponentInfo(componentName);
                nComponentInfo = { ...(res?.result), totalWidth: res?.totalWidth || 0 };
            }
            setHttpFormData(nComponentInfo?.formData || []);
        } catch (error) {
            console.log(error);
        };
    };

    // 保存
    const handleSave = () => {
        let autoLoading = props?.autoLoading || '';
        if (autoLoading !== 'N') {
            if (okLoading) return;
            setLoading(true);
        }
        formRef && formRef.current && formRef.current.handleSave('Y')
            .then(result => {
                if (!(result?.error)) {
                    if (props?.componentsSelectFlag === 'Y') { // 关联数据回传
                        result[linkDataFiled] = linkData;
                    }
                    props.handleSave && props.handleSave(result);
                } else {
                    setLoading(false);
                }
            })
    };

    // 获取数据
    const getFieldsValue = () => {
        let fromValues = formRef && formRef.current && formRef.current.getFieldsValue();
        if (props?.componentsSelectFlag === 'Y') { // 关联数据回传
            fromValues[linkDataFiled] = linkData;
        }
        return {
            ...fromValues,
        }
    };

    // 关闭弹窗
    const handleCancel = () => {
        if (props && 'recordFormInput' in props && props.recordFormInput) { // 关闭弹窗的时候记录表单输入的值
            let fieldsValue = getFieldsValue();
            props.recordFormInput && props.recordFormInput(fieldsValue);
        }
        modifyVisible(false);
    };

    // 关联组件
    const handleSelectComponent = () => {
        selectComponentsRef && selectComponentsRef.current && selectComponentsRef.current.modifyVisible(true, linkData);
    };

    // 确认关联
    const handleConfirmLink = (linkData) => {
        setLinkData(Util.customDeepCopy(linkData));
    };

    // 切换tab，修改父组件数据
    const handleTabChange = record => {
        setDrawerWidth(record?.width || '');
    };

    const { title, height, okText, cancelText, className = '', width, idField, rowData, selectData, formData, componentsSelectFlag, linkFormLabel, linkFormField, mask = true } = props;

    const currentFormData = httpFormData && Array.isArray(httpFormData) && httpFormData.length > 0 ? httpFormData : formData;

    // 基本信息表单
    const baseInfoDom = (
        <>
            <div
                style={{
                    overflow: 'auto',
                    paddingRight: '6px',
                    paddingTop: linkTabData && Array.isArray(linkTabData) && linkTabData.length > 0 ? '12px' : 0,
                    height: (height || (documentHeight - 126 - (linkTabData && Array.isArray(linkTabData) && linkTabData.length > 0 ? 36 : 0) + 'px')),
                }}
            >
                {/* 关联数据展示 */}
                {linkData && Array.isArray(linkData) && linkData.length > 0 ? (
                    <Row style={{ marginBottom: '10px' }}>
                        <Col
                            style={{ textAlign: 'end', paddingRight: '8px' }}
                            className="ant-form-item-label"
                            span={currentFormData && currentFormData.length > 0 ? (currentFormData[0]?.labelCol || 24) : 24}
                        >
                            <label>
                                {linkFormLabel || '关联数据'}
                                <span style={{ marginLeft: '2px' }}>:</span>
                            </label>
                        </Col>
                        <Col span={currentFormData && currentFormData.length > 0 ? (currentFormData[0]?.wrapperCol || 24) : 24}>
                            {linkData && linkData.map((item, index) => {
                                return (
                                    <div key={index}>
                                        {(index + 1) + '、'}
                                        {linkFormField && linkFormField in item ? item.linkFormField : (item?.componentDesc || '') + '(' + (item?.componentCode || '') + '}'}
                                    </div>
                                )
                            })}
                        </Col>
                    </Row>
                ) : ''}
                <DynamicRenderingForm
                    idField={idField}
                    selectData={selectData}
                    rowData={rowData}
                    formData={currentFormData}
                    formItemCol={{ labelCol: 24, wrapperCol: 24, col: 24 }}
                    ref={formRef}
                />
            </div>
            <div style={{ textAlign: 'center', paddingTop: '12px', borderTop: '1px solid #e8e8e8' }}>
                <Button type="primary" loading={okLoading} onClick={handleSave}>
                    {okText || ((rowData && ((idField && rowData[idField]) || ('id' in rowData && rowData.id))) ? '确认修改' : '保存')}
                </Button>
                <Button style={{ marginLeft: '24px' }} onClick={handleCancel}>
                    {cancelText || ((rowData && ((idField && rowData[idField]) || ('id' in rowData && rowData.id))) ? '取消修改' : '取消')}
                </Button>
            </div>
        </>
    );

    return (
        <div key={interfaceKey}>
            <Drawer
                mask={mask}
                open={visible}
                title={title || ((rowData && ((idField && rowData[idField]) || ('id' in rowData && rowData.id))) ? '编辑' : '添加')}
                width={drawerWidth || width || '560px'}
                className={[className, linkTabData && linkTabData.length > 0 ? 'public-drawer-body-top0' : '', 'public-drawer-form-hook'].join(' ')}
                extra={
                    <Space>
                        {componentsSelectFlag === 'Y' && (
                            <span
                                className="common-record-span"
                                style={{ fontSize: '14px' }}
                                onClick={handleSelectComponent}
                            >
                                <LinkOutlined style={{ marginRight: '2px' }} />
                                菜单关联组件
                            </span>
                        )}
                    </Space>
                }
                onClose={() => setVisible(false)}
            >
                <div>
                    {linkTabData && linkTabData.length > 0 ? (
                        <TabsComponent
                            rowData={rowData}
                            selectData={selectData}
                            baseInfoDom={baseInfoDom}
                            linkTabData={linkTabData}
                            onChange={handleTabChange}
                        />
                    ) : (
                        baseInfoDom
                    )}
                </div>
            </Drawer>

            {/* 菜单关联选择 */}
            {componentsSelectFlag === 'Y' && (
                <MenuAssociatedComponents
                    ref={selectComponentsRef}
                    componentName={props?.associatedComponentName || 'ComponentDataMaintenance'}
                    queryCode={props?.associatedQueryCode || '01010022'}
                    hidePaginationFlag={props?.hideAssociatedPaginationFlag || 'N'}
                    onOk={handleConfirmLink}
                />
            )}
        </div>
    )
};

export default forwardRef(PublicDrawerFormHook);