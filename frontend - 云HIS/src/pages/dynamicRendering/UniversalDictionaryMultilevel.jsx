/*
 * Create:      柿子
 * CreateDate:  2024/057/11
 * Describe：   树状字典维护（多层级）
 * */
import React, { useEffect, useState, useMemo, useRef } from 'react';
import { Row, Col, Input, Tree, Card, Button, Form, Checkbox, Radio, TreeSelect, message, Spin, Modal, Space, Tag } from 'antd';
import { CloseCircleOutlined, CheckCircleOutlined, DownOutlined } from '@ant-design/icons';
import { Util } from '@tools';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import UseSyncCallback from '@pages/common/UseSyncCallback';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import './style/index.less';

const UniversalDictionaryMultilevel = (props) => {
    let dictionaryRef = useRef(null);
    const userData = React.$getSessionData();
    const formItemLayout = {
        labelCol: { span: 3 },
        wrapperCol: { span: 12 },
    };
    const formRef = React.createRef();
    const isFirstRender = useRef(true);
    const [effectiveFlag, setEffectiveFlag] = useState('Y'); // 仅显示生效
    const [treeData, setTreeData] = useState([]);
    const [typeID, setTypeID] = useState('3');
    const [saveLoading, setSaveLoading] = useState(false);
    const [treeLading, setTreeLoading] = useState(false);
    const [channelList, setChannelList] = useState([]); // 上级分类数据
    const [expandedKeys, setExpandedKeys] = useState([]);
    const [selectedKeys, setSelectedKeys] = useState([]); // 树选中key
    const [selectedDataRef, setSelectedDataRef] = useState({}); // 树选中数据
    const [searchValue, setSearchValue] = useState('');
    const [autoExpandParent, setAutoExpandParent] = useState(true);

    const [categoryData, setCategoryData] = useState({});
    const [currentMenuData, setCurrentMenuData] = useState({}); // 当前菜单
    const [dictionaryTypeVisible, setDictionaryTypeVisible] = useState(false);
    const [dictionaryTypeColumns, setDictionaryTypeColumns] = useState([]);
    const [dictionaryTypeTableFromData, setDictionaryTypeFormData] = useState([]);
    const [dictionaryTypeTableData, setDictionaryTypeTableData] = useState([]);
    const [dictionaryTypeTotal, setDictionaryTypeTotal] = useState(0);
    const [dictionaryTypePage, setDictionaryTypePage] = useState(1);
    const [dictionaryTypePageSize, setDictionaryTypePageSize] = useState(20);
    const [dictionaryTypeLoading, setDictionaryTypeLoading] = useState(false);
    const [dictionaryTypeRowID, setDictionaryTypeRowID] = useState('');
    const [dictionaryTypeRowData, setDictionaryTypeRowData] = useState({});

    useEffect(() => {
        let newCategory;
        if ('paras' in props && props.paras && props.paras.params) { // 侧菜单获取类别参数
            newCategory = props?.paras?.params || '';
        } else {
            if (location && location.state && location.state.params) { // 头菜单获取类别参数、
                newCategory = location?.state?.params || '';
                React.$setSessionData('UniversalDictionaryMultilevel', newCategory, false);
            } else { // 头菜单刷新界面时获取类别
                newCategory = React.$getSessionData('UniversalDictionaryMultilevel', false);
            }
        };
        if (newCategory) {
            let categoryData = Util.getObjByUrlStr(newCategory);
            console.log('UniversalDictionaryMultilevel', categoryData);
            setCategoryData(categoryData);
            if (categoryData?.multiLevelFlag === 'Y') { // 是否需要切换类型维护对应的列表数据
                if (categoryData?.typeSelectMethod !== 'menu') { // 选择类型为下拉菜单方式
                    getDictionaryTypeColumns(categoryData);
                }
                getDictionaryTypeData(1, {}, 'Y', categoryData);
            }
        } else {
            message.error('界面参数还未配置，快去配置先！')
        }
    }, []);

    useEffect(() => {
        currentMenuData && JSON.stringify(currentMenuData) !== '{}' && categoryData?.multiLevelFlag === 'Y' && getTreeData();
    }, [currentMenuData])

    useEffect(() => {
        if (isFirstRender.current) { // 第一次默认加载
            isFirstRender.current = false;
        } else {
            getTreeData();
        }
    }, [effectiveFlag]);

    // 获取左侧渠道目录数据
    const getTreeData = async () => {
        try {
            let queryCode = categoryData?.queryCode || '';
            if (!queryCode) return;
            setTreeLoading(true);
            let data = {
                params: [{
                    [categoryData?.typeDataIndex || 'typeID']: categoryData?.multiLevelFlag === 'Y' ? (currentMenuData?.id || undefined) : undefined, // 根据类型切换相对应的字典维护
                    status: effectiveFlag
                }]
            }
            const res = await React.$asyncPost(selectCode, data);
            let treeData = processTreeData(res?.data?.rows || res?.data?.channel || []);
            setTreeData(treeData);
            setChannelList(treeData);
            if (treeData && treeData.length > 0) {
                let expandedKeys = getExpandedKeys(treeData);
                setExpandedKeys(expandedKeys);
            }
        } catch (error) {
            console.log('error', error);
            setTreeLoading(false);
        }
    };

    // 获取展开树数据
    const processTreeData = data => {
        return data.map(item => {
            let newNode = { ...item, key: item?.id || '', value: item?.id || '', title: item?.descripts || item?.fullDesc || '' };
            if (item.children) {
                newNode.children = processTreeData(item.children);
            }
            return newNode;
        });
    };

    // 获取展开树数据
    const getExpandedKeys = data => {
        let keys = [];
        const traverse = node => {
            if (node.children) {
                keys.push(node.key);
                node.children.forEach(childNode => traverse(childNode));
            }
        };
        data.forEach(item => traverse(item));
        return keys;
    };

    let dataList = [];
    const generateList = (data) => {
        for (let i = 0; i < data.length; i++) {
            const node = data[i];
            dataList.push({
                ...node
            });
            if (node.children) {
                generateList(node.children);
            }
        }
    };

    generateList(treeData);
    const getParentKey = (key, tree) => {
        let parentKey;
        for (let i = 0; i < tree.length; i++) {
            const node = tree[i];
            if (node.children) {
                if (node.children.some((item) => item.key === key)) {
                    parentKey = node.key;
                } else if (getParentKey(key, node.children)) {
                    parentKey = getParentKey(key, node.children);
                }
            }
        }
        return parentKey;
    };

    const handleExpand = (newExpandedKeys) => {
        setExpandedKeys(newExpandedKeys);
        setAutoExpandParent(false);
    };

    const handleTreeSelect = (selectedKeys, event) => {
        let dataRef = event.node?.dataRef || {};
        setSelectedKeys(selectedKeys);
        setSelectedDataRef(dataRef);
        setTypeID('1');
        // 表单赋值【编辑】
        formRef.current.setFieldsValue({
            type: '1',
            parentID: dataRef?.parentID || undefined,
            code: dataRef?.code || undefined,
            descripts: dataRef?.descripts || undefined,
            remark: dataRef?.remark || undefined,
            status: dataRef?.status === 'Y'
        })
    };

    const handleTreeSearchValChange = (e) => {
        const { value } = e.target;
        const newExpandedKeys = dataList
            .map((item) => {
                if (item?.title?.indexOf(value) > -1) {
                    return getParentKey(item.key, treeData);
                }
                return null;
            })
            .filter((item, i, self) => item && self.indexOf(item) === i);
        setExpandedKeys(newExpandedKeys);
        setSearchValue(value);
        setAutoExpandParent(true);
    };

    // 渲染渠道目录树数据
    const renderTreeData = useMemo(() => {
        const loop = (data) =>
            data.map((item) => {
                const strTitle = item?.title || '';
                const index = strTitle.indexOf(searchValue);
                const beforeStr = strTitle.substring(0, index);
                const afterStr = strTitle.slice(index + searchValue.length);
                const title =
                    index > -1 ? (
                        <span style={{ color: item?.status === 'N' ? '#999' : '' }}>
                            {beforeStr}
                            <span style={{ color: '#f50' }}>{searchValue}</span>
                            {afterStr}
                        </span>
                    ) : (
                        <span style={{ color: item?.status === 'N' ? '#999' : '' }}>{strTitle}</span>
                    );
                if (item.children) {
                    return {
                        title,
                        key: item?.id || item?.key || '',
                        children: loop(item.children),
                        dataRef: item
                    };
                }
                return {
                    title,
                    key: item?.id || item?.key || '',
                    dataRef: item
                };
            });
        return loop(treeData);
    }, [searchValue, treeData]);

    // 保存
    const handleSave = () => {
        try {
            let saveCode = typeID === '1' ? (categoryData?.editCode || '') : (categoryData?.saveCode || '');
            if (!saveCode) return;
            setSaveLoading(true);
            formRef.current.validateFields()
                .then(async values => {
                    let data = {
                        params: [{
                            [categoryData?.typeDataIndex || 'typeID']: categoryData?.multiLevelFlag === 'Y' ? (currentMenuData?.id || undefined) : undefined, // 根据类型切换相对应的字典维护
                            ...values,
                            status: values?.status ? 'Y' : 'N',
                            id: typeID === '1' ? (selectedDataRef?.id || '') : undefined,
                        }]
                    }
                    const res = await React.$asyncPost(saveCode, data);
                    message.success(res?.msg || '保存成功');
                    getTreeData();
                    typeID !== '1' && handleFormReset();
                })
                .catch(error => {
                    console.log(error);
                    setSaveLoading(false);
                })
        } catch (error) {
            console.log(error);
            setSaveLoading(false);
        }
    };

    // 清空
    const handleFormReset = UseSyncCallback(() => {
        if (typeID === '1') {
            formRef && formRef.current && formRef.current.setFieldsValue({
                code: undefined,
                descripts: undefined,
                parentID: undefined,
                remark: undefined,
                status: true
            });
        } else {
            formRef && formRef.current && formRef.current.setFieldsValue({
                code: undefined,
                descripts: undefined,
                remark: undefined,
                status: true
            });
        }
    });

    // 仅显示生效
    const handleEffectiveFlagChange = e => {
        setEffectiveFlag(e.target.checked ? 'Y' : 'N');
        handleAllReset();
    };

    const handleAllReset = () => {
        setSelectedKeys([]);
        setSelectedDataRef({});
        setTypeID('3');
        formRef.current.setFieldsValue({
            type: '3',
            code: undefined,
            descripts: undefined,
            remark: undefined,
            parentID: undefined,
            status: true
        });
    };

    // 类型切换
    const handleTypeChange = e => {
        let type = e.target.value;
        setTypeID(type);
        formRef.current.setFieldsValue({
            code: type === '1' ? selectedDataRef?.code : undefined,
            descripts: type === '1' ? selectedDataRef?.descripts : undefined,
            parentID: type === '2' ? selectedDataRef?.id : selectedDataRef?.parentID,
            remark: type === '1' ? selectedDataRef?.remark : undefined,
            status: type === '1' && selectedDataRef?.status !== 'Y' ? false : true
        });
    };

    // 获取多选菜单数据
    const getMultipleChoiceMenu = () => {
        return <Menu>
            {dictionaryTypeTableData && Array.isArray(dictionaryTypeTableData) && dictionaryTypeTableData.map((item, index) => {
                return <Menu.Item key={item?.id || (index + 1)} onClick={() => setCurrentMenuData(item)}>{item?.label || item?.descripts || ''}</Menu.Item>
            })}
        </Menu>
    };

    // 字典类型数据查询
    const handleDictionaryQuery = () => {
        getDictionaryTypeData(1, values)
    };

    // 获取字典类型数据
    const getDictionaryTypeData = async (dictionaryTypePage, values = {}, defaultFlag, propCategoryData = {}) => {
        try {
            let selectCode = categoryData?.selectCode || propCategoryData?.selectCode || '';
            if (selectCode !== '') {
                setDictionaryTypeLoading(true);
                setDictionaryTypePage(dictionaryTypePage ? dictionaryTypePage : 1);
                let data = {
                    params: [{
                        [categoryData?.typeDataIndex || 'typeID']: categoryData?.multiLevelFlag === 'Y' ? (currentMenuData?.id || undefined) : undefined, // 根据类型切换相对应的字典维护
                        ...values,
                        pageSize: dictionaryTypePageSize,
                        currentPage: dictionaryTypePage ? dictionaryTypePage : 1
                    }]
                }
                const res = await React.$asyncPost(selectCode, data);
                let tableData = res?.data?.rows || res?.data?.channel || [];
                setDictionaryTypeTableData(tableData);
                setDictionaryTypeTotal(res?.data?.totalCount || tableData?.length || 0);
                if (defaultFlag === 'Y' && tableData && Array.isArray(tableData) && tableData.length > 0) {
                    setCurrentMenuData(tableData[0]);
                }
            }
        } catch (error) {
            console.log(error);
            setDictionaryTypeLoading(false);
        }
    };

    // 确定选择
    const handleDictionaryTypeOk = () => {
        if (!dictionaryTypeRowID) {
            message.error('请选择需要切换的字典类型！');
            return;
        }
        setDictionaryTypeVisible(false);
        setCurrentMenuData(dictionaryTypeRowData);
    };

    const handleDictionaryTypePageChange = (page, pageSize) => {
        setDictionaryTypePage(page)
        setDictionaryTypePageSize(pageSize);
        getDictionaryTypeData(page)
    };

    /**
     * 获取并设置字典类型的列和表单数据
     * @param {Object} propCategoryData - 传入的属性类别数据
     */
    const getDictionaryTypeColumns = async (propCategoryData) => {
        try {
            const componentName = categoryData?.typeSelectModalColumnCode || propCategoryData?.typeSelectModalColumnCode || '';
            if (!componentName) return;
            const data = {
                params: [{ componentName }]
            };
            const res = await React.$asyncPost('01040073', data);
            // 获取列数据并设置排序后的列
            const columnData = res.result?.C || [];
            const sortedColumns = columnsSortRender(columnData);
            setDictionaryTypeColumns(sortedColumns);
            // 获取表单数据并设置表单项行为
            const formData = res.result?.formData || [];
            const updatedFormData = formData.map(item => {
                if (['Input'].includes(item?.typeCode) || ['Input'].includes(item?.fieldTypeCode || item?.dataIndex)) {
                    item.onPressEnter = handleDictionaryQuery;
                }
                if (item?.code === 'queryBtn' || item?.dataIndex === 'queryBtn') {
                    item.onClick = handleDictionaryQuery;
                }
                return item;
            });
            setDictionaryTypeFormData(updatedFormData);
        } catch (error) {
            console.error('error', error);
        }
    };

    // 自定义操作栏
    const columnsSortRender = (column) => {
        let columns = []
        JSON.parse(JSON.stringify([...column].sort((a, b) => a.seqNo > b.seqNo ? 1 : -1))).forEach((item) => {
            if (item.display === 'Y') {
                columns.push(
                    {
                        ...item,
                        render: (text) => {
                            if (item.dataIndex === 'status') {
                                if (text === 'Y') {
                                    return <Tag icon={<CheckCircleOutlined />} color="success">使用中</Tag>
                                } else if (text === 'N') {
                                    return <Tag icon={<CloseCircleOutlined />} color="error">停用中</Tag>
                                }
                            } else {
                                return <span>{text}</span>
                            }
                        }
                    }
                )
            }
        })
        return columns
    };

    // 字典类型选择
    const handleTypeSelectMethod = () => {
        setDictionaryTypeVisible(true);
        getDictionaryTypeData();
    };

    // 操作行
    const handleDictionaryTypeRowClick = (record) => {
        return {
            onClick: () => {
                // 保存行数据以及ID
                if (dictionaryTypeRowID === '' || dictionaryTypeRowID !== record.id) {
                    setDictionaryTypeRowID(record.id);
                    setDictionaryTypeRowData(record);
                } else {
                    setDictionaryTypeRowID('');
                    setDictionaryTypeRowData({});
                }
            }
        }
    };

    // 选中行操作
    const handleDictionaryTypeRowClassName = (record) => {
        return record.id === dictionaryTypeRowID ? 'clickRowStyle' : '';
    };

    const userSafeClassificat = parseFloat(userData && 'safeClassificat' in userData ? userData.safeClassificat : 1);
    const menuSafeClassificat = parseFloat(currentMenuData && 'safeClassificat' in currentMenuData ? currentMenuData.safeClassificat : 1);

    return (
        <div className="universal-dictionary-multilevel">
            <Row>
                <Col span={8} style={{ paddingRight: 10 }}>
                    <Card
                        size="small"
                        title={(
                            <div className="common-card-title-icon">
                                <div></div>
                                {categoryData?.multiLevelFlag === 'Y' ? (
                                    categoryData?.typeSelectMethod === 'menu' ? (
                                        <Dropdown
                                            overlay={getMultipleChoiceMenu()}
                                        >
                                            <a onClick={e => e.preventDefault()}>
                                                <Space>
                                                    {currentMenuData?.descripts || ''}
                                                    <DownOutlined />
                                                </Space>
                                            </a>
                                        </Dropdown>
                                    ) : (
                                        <div>
                                            <span style={{ color: '#1890ff', cursor: 'pointer' }} onClick={handleTypeSelectMethod}>
                                                <Space>
                                                    {currentMenuData?.descripts || ''}
                                                    <DownOutlined style={{ marginTop: '4px' }} />
                                                </Space>
                                            </span>
                                            <span style={{ color: '#999', fontSize: '12px', marginLeft: '20px' }}>
                                                {props?.typeSelectMethodBtn === 'Y' ? (
                                                    "(提醒：点击 '切换字典类型' 按钮切换字典类型维护对应字典。)"
                                                ) : (
                                                    "( ⬅ 可切换字典类型 )"
                                                )}
                                            </span>
                                        </div>
                                    )
                                ) : (categoryData?.cardTitle || '渠道目录')}
                            </div>
                        )}
                        extra={(
                            <Checkbox checked={effectiveFlag === 'Y' ? true : false} onChange={handleEffectiveFlagChange}>仅显示生效</Checkbox>
                        )}
                    >
                        <div style={{ marginBottom: 8 }}>
                            <Input
                                style={{
                                    width: '100%',
                                    marginRight: 12
                                }}
                                placeholder="请输入渠道搜索"
                                value={searchValue}
                                onChange={handleTreeSearchValChange}
                            />
                        </div>
                        <Spin spinning={treeLading} tip="数据加载中...">
                            <div>
                                <Tree
                                    expandedKeys={expandedKeys}
                                    selectedKeys={selectedKeys}
                                    autoExpandParent={autoExpandParent}
                                    onExpand={handleExpand}
                                    onSelect={handleTreeSelect}
                                    treeData={renderTreeData}
                                />
                            </div>
                        </Spin>
                    </Card>
                </Col>
                <Col span={16}>
                    <Card
                        size="small"
                        title={<div className="common-card-title-icon"><div></div>渠道维护</div>}
                    >
                        <Form
                            ref={formRef}
                            className="cd-right-form"
                            {...formItemLayout}
                        >
                            <Row>
                                <Col span={24}>
                                    <Form.Item
                                        label="操作类型"
                                        name="type"
                                        initialValue={selectedDataRef?.type || '3'}
                                    >
                                        <Radio.Group onChange={handleTypeChange}>
                                            <Radio value="1" disabled={!(selectedKeys && selectedKeys.length > 0)}>编辑分类</Radio>
                                            <Radio value="2" disabled={!(selectedKeys && selectedKeys.length > 0)}>新增子类</Radio>
                                            <Radio value="3">新增同级分类</Radio>
                                        </Radio.Group>
                                    </Form.Item>
                                </Col>
                                <Col span={24}>
                                    <Form.Item
                                        label="代码"
                                        name="code"
                                        initialValue={selectedDataRef?.code || undefined}
                                        rules={[{ required: true, message: '代码不能为空' }]}
                                    >
                                        <Input style={{ width: '100%' }} allowClear placeholder="请输入" />
                                    </Form.Item>
                                </Col>
                                <Col span={24}>
                                    <Form.Item
                                        label="描述"
                                        name="descripts"
                                        initialValue={selectedDataRef?.descripts || undefined}
                                        rules={[{ required: true, message: '描述不能为空' }]}
                                    >
                                        <Input style={{ width: '100%' }} allowClear placeholder="请输入" />
                                    </Form.Item>
                                </Col>
                                <Col span={24}>
                                    <Form.Item
                                        label="备注"
                                        name="remark"
                                        initialValue={selectedDataRef?.remark || undefined}
                                    >
                                        <Input style={{ width: '100%' }} allowClear placeholder="请输入" />
                                    </Form.Item>
                                </Col>
                                <Col span={24}>
                                    <Form.Item
                                        label="上级分类"
                                        name="parentID"
                                        initialValue={selectedDataRef?.parentID || undefined}
                                    >
                                        <TreeSelect
                                            placeholder="请选择"
                                            disabled={!(selectedKeys && selectedKeys.length > 0 && typeID === '1')}
                                            treeData={channelList}
                                        ></TreeSelect>
                                    </Form.Item>
                                </Col>
                                <Col span={24}>
                                    <Form.Item
                                        label="是否生效"
                                        name="status"
                                        valuePropName="checked"
                                        initialValue={selectedDataRef?.status === 'N' ? false : true}
                                    >
                                        <Checkbox />
                                    </Form.Item>
                                </Col>
                            </Row>
                        </Form>
                        <Row>
                            <Col span={3}></Col>
                            <Col span={16}>
                                <Button style={{ marginRight: '20px' }} onClick={handleFormReset}>清空</Button>
                                <Button
                                    type="primary"
                                    loading={saveLoading}
                                    disabled={typeID === '1' ? !(userSafeClassificat >= menuSafeClassificat) : !(userSafeClassificat > 0)}
                                    onClick={(typeID === '1' ? (userSafeClassificat >= menuSafeClassificat) : (userSafeClassificat > 0)) && handleSave}
                                >
                                    {typeID === '1' ? '确认修改' : '保存'}
                                </Button>
                            </Col>
                        </Row>
                    </Card>
                </Col>
            </Row>

            <Modal
                title={categoryData?.typeSelectTitle || '切换字典类型'}
                width={1300}
                open={dictionaryTypeVisible}
                onCancel={() => setDictionaryTypeVisible(false)}
                onOk={handleDictionaryTypeOk}
            >
                <div id="search-bar" style={{ display: dictionaryTypeTableFromData && dictionaryTypeTableFromData.length > 0 ? 'block' : 'none' }}>
                    <DynamicRenderingForm
                        autoFocusFlag="Y"
                        rowData={{}}
                        formData={dictionaryTypeTableFromData}
                        ref={dictionaryRef}
                    />
                </div>
                <div>
                    <PublicTablePagination
                        param={{
                            columns: dictionaryTypeColumns,
                            data: dictionaryTypeTableData,
                            total: dictionaryTypeTotal,
                            page: dictionaryTypePage,
                            pageSize: dictionaryTypePageSize,
                            loading: dictionaryTypeLoading,
                            bordered: false,
                            y: 400,
                            height: '450px'
                        }}
                        compilePage={handleDictionaryTypePageChange}
                        onClickRowPublic={handleDictionaryTypeRowClick}
                        setRowClassNamePublic={handleDictionaryTypeRowClassName}
                    />
                </div>
            </Modal>
        </div>
    )
};

export default UniversalDictionaryMultilevel;

// 多层级通用字典维护: params=interfaceType:universalDictionary&typeSelectModalColumnCode:UniversalDictionaryMaintenanceTypeModal&queryCode:123&saveCode:123&editCode:123&multiLevelFlag:Y&selectCode:123&typeSelectMethod:modal