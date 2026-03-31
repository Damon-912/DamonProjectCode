/*
 * Create:      柿子
 * CreateDate:  2023/05/18
 * Describe：   界面动态配置-界面参数维护
 * */
import React, { useEffect, useState, useRef, useCallback } from 'react';
import { Dropdown, message, Popconfirm, Tabs, Button, Empty } from 'antd';
import { PlusOutlined, BulbOutlined, EllipsisOutlined, DeleteOutlined, EditOutlined } from '@ant-design/icons';
import { Util } from '@tools';
import * as Icon from '@ant-design/icons';
import store from '@store';
import PublicImagePreview from '@pages/common/PublicImagePreview';
import PublicDrawerFormHook from '@pages/common/PublicDrawerFormHook';
import SingleTableParamsConfig from './component/SingleTableParamsConfig';
import UniversalDictionaryParamsConfig from './component/UniversalDictionaryParamsConfig';
import singleTableImg from './images/single-table.png';
import singleTablePreviewImg from './images/single-table-preview.png';
import './style/index.less';

const InterfaceParameterMaintenance = () => {
    let imagePreviewRef = useRef(null);
    let drawerFormRef = useRef(null);
    let singleConfigRef = useRef(null);
    let universalDictionaryConfigRef = useRef(null);
    const { contentHeight } = store.getState();
    const interfaceTypeData = [{
        key: 'params=interfaceType:singleTable',
        id: 'params=interfaceType:singleTable',
        label: '单表操作',
        title: '单表增删改查界面配置',
        icon: 'AlertOutlined',
        linkAddress: 'pages/dynamicRendering/SingleTableOperation.jsx',
        params: 'params=interfaceType:singleTable&componentName:MenuDetailMaintenance&selectCode:01040100&queryCode:01040104&deleteCode:01040103&saveCode:01040101&saveCode:01040101&idField:menuDetailID&operationBtnPosition:queryRight&componentsSelectFlag:Y',
        introduceDesc: '查询条件，列表信息可动态配置。功能按钮根据维护的对应接口代码展示。',
        images: singleTableImg, // 缩略图
        previewImages: singleTablePreviewImg
    }, {
        key: 'params=interfaceType:universalDictionary',
        id: 'params=interfaceType:universalDictionary',
        label: '树型数据维护',
        title: '多层级字典数据维护(树状型)',
        icon: 'AlertOutlined',
        linkAddress: 'pages/dynamicRendering/UniversalDictionaryMultilevel.jsx',
        params: 'params=interfaceType:universalDictionary&typeSelectModalColumnCode:UniversalDictionaryMaintenanceTypeModal&queryCode:123&saveCode:123&editCode:123&multiLevelFlag:Y&selectCode:123&typeSelectMethod:modal',
        introduceDesc: '左右结构，左侧目录树，右侧表单数据维护。',
        images: singleTableImg, // 缩略图
        previewImages: singleTablePreviewImg
    }, {
        key: 'params=interfaceType:parentChildTable',
        label: '父子表操作',
        title: '父子表增删改查界面配置',
        icon: 'PicCenterOutlined',
        linkAddress: 'pages/dynamicRendering/ParentChildTableOperation.jsx',
        params: 'params=interfaceType:parentChildTable',
        introduceDesc: '左右结构，查询条件，列表信息可动态配置。功能按钮根据维护的对应接口代码展示。',
        images: singleTableImg, // 缩略图
        previewImages: singleTablePreviewImg
    }];
    const [tableData, setTableData] = useState([]);
    const [activeTabKey, setActiveTabKey] = useState('');
    const [activeTabRecord, setActiveTabRecord] = useState({});
    const [drawerRowData, setDrawerRowData] = useState({});
    const [selectData, setSelectData] = useState({});

    useEffect(() => {
        if (interfaceTypeData && Array.isArray(interfaceTypeData) && interfaceTypeData.length > 0) {
            handleTabChange(interfaceTypeData[0]?.key || interfaceTypeData[0]?.id || '');
        }
        getSelectData();
    }, []);

    const getSelectData = async () => {
        try {
            // 获取字段类型下拉数据
            const res = await React.$asyncPost('01010027');
            setSelectData(res);
        } catch (error) {
            console.log('error', error)
        }
    };

    // 切换页签
    const handleTabChange = key => {
        const nActiveTabRecord = Util.returnDataCccordingToAttributes(interfaceTypeData, key, 'key');
        setActiveTabKey(key);
        setActiveTabRecord(nActiveTabRecord);
    };

    useEffect(() => {
        activeTabKey && getTableData();
    }, [activeTabKey])

    // 获取界面数据
    const getTableData = async () => {
        try {
            const data = {
                params: [{
                    paras: activeTabKey || 'params=interfaceType:singleTable',
                }],
                pagination: [{
                    pageSize: 10000,
                    currentPage: 1,
                }]
            };
            const res = await React.$asyncPost('01040104', data);
            setTableData(filterTableData(React.$processingTableRequestData(res)));
        } catch (error) {
            console.log(error);
        };
    };

    // 处理列表数据
    const filterTableData = (data) => {
        if (data && Array.isArray(data) && data.length > 0) {
            return data.map((item, index) => {
                return {
                    ...item,
                    key: index,
                    ...getValueByParas(item?.paras || ''),
                }
            })
        } else {
            return [];
        }
    };

    // 解析参数 - interfaceType - 界面类型(单表增删改查:singleTable/parentChildTable)
    const getValueByParas = (params) => {
        let paramObj = {};
        try {
            if (params && params.indexOf('=') > -1) { // 动态配置界面params=
                const [equalSignKey, urlStr] = params.split('=');
                paramObj.equalSignKey = equalSignKey;
                if (urlStr && urlStr.indexOf('&') > -1) {
                    let paramsData = urlStr.split('&');
                    for (let i = 0; i < paramsData.length; i++) {
                        if (paramsData[i].indexOf(':') > -1) {
                            const [key, value] = paramsData[i].split(':');
                            paramObj[key] = value;
                        }
                    }
                } else if (urlStr && urlStr.indexOf(':') > -1) {
                    const [key, value] = urlStr.split(':');
                    paramObj[key] = value;
                }
            }
        } catch (error) {
            console.log(error)
        }
        return { ...paramObj, interfaceType: ('params=interfaceType:' + (paramObj?.interfaceType || 'other')) };
    };

    // 删除
    const handleDelete = async (record, e) => {
        try {
            React.$stopPropagation(e);
            let data = {
                params: [{
                    menuDetailID: record?.menuDetailID || undefined
                }]
            }
            const res = await React.$asyncPost('01040103', data);
            message.success(res?.errorMessage || '删除成功');
            getTableData();
        } catch (error) {
            console.log(error);
        }
    };

    // 编辑
    const handleCompile = (record, e) => {
        React.$stopPropagation(e);
        setDrawerRowData(record);
        drawerFormRef && drawerFormRef.current && drawerFormRef.current.modifyVisible(true);
    };

    // 新增
    const handleAdd = () => {
        if (drawerRowData && 'menuDetailID' in drawerRowData && drawerRowData.menuDetailID) {
            setDrawerRowData({});
        };
        drawerFormRef && drawerFormRef.current && drawerFormRef.current.modifyVisible(true);
    };

    // 查看界面轮廓
    const handleViewInterfaceOutline = () => {
        imagePreviewRef && imagePreviewRef.current && imagePreviewRef.current.modifyVisible(true, activeTabRecord?.images || '');
    };

    // 保存
    const handleAddSave = async (values) => {
        try {
            const nActiveTabRecord = Util.returnDataCccordingToAttributes(interfaceTypeData, values?.interfaceType || activeTabKey, 'key');
            const res = await React.$asyncPost('01040101', {
                params: [{
                    ...drawerRowData,
                    ...values,
                    linkAddress: nActiveTabRecord?.linkAddress || '',
                    paras: drawerRowData?.paras || (nActiveTabRecord?.key || activeTabKey || ''),
                    menuGroup: 'N', // 菜单组标志
                }]
            });
            message.success(res?.errorMessage || '保存成功');
            drawerFormRef && drawerFormRef.current && drawerFormRef.current.modifyVisible(false, 'Y');
            getTableData();
        } catch (error) {
            console.log(error);
            drawerFormRef && drawerFormRef.current && drawerFormRef.current.modifyOkLoading(false);
        }
    };

    // 界面参数配置
    const handleInterfaceParamsConfig = (record) => {
        switch (activeTabKey) {
            case 'params=interfaceType:singleTable':
                singleConfigRef && singleConfigRef.current && singleConfigRef.current.modifyVisible(true, record); // 单表
                break;
            case 'params=interfaceType:universalDictionary':
                universalDictionaryConfigRef && universalDictionaryConfigRef.current && universalDictionaryConfigRef.current.modifyVisible(true, record); // 多级字典
                break;
            default:
                break;
        };
    }

    // 动态创建图标组件
    const iconBC = useCallback((name) => React.createElement(Icon[name]), []);

    // 获取tabs
    const tabsItems = () => {
        return interfaceTypeData && interfaceTypeData.map(item => {
            return {
                ...item,
                icon: item && 'icon' in item && typeof (item.icon) === 'string' ? iconBC(item.icon) : ''
            }
        })
    };

    const dataGroupFlag = !!(interfaceTypeData && Array.isArray(interfaceTypeData) && interfaceTypeData.length > 1);
    return (
        <div className="interface-parameter-maintenance flex">
            {dataGroupFlag && (
                <div className="ipm-tabs sto-data-group-col">
                    <Tabs
                        tabPosition="left"
                        items={tabsItems()}
                        activeKey={activeTabKey}
                        onChange={handleTabChange}
                    />
                </div>
            )}
            {/* <h3>单表界面管理</h3> */}
            <div style={{ width: dataGroupFlag ? 'calc(100% - 120px)' : '100%' }}>
                <div style={{ paddingLeft: dataGroupFlag ? '6px' : '0', height: contentHeight + 'px', position: 'relative' }}>
                    <div style={{ width: '100%', height: '100%', overflow: 'auto' }} className="ipm-body">
                        <div className="ipm-body-title">
                            <h3>
                                {activeTabRecord?.title || ''}
                            </h3>
                            <p>
                                {activeTabRecord?.introduceDesc || activeTabRecord?.doubt || ''}
                                不知道配置的界面长啥样？你还可以 <span className="common-record-span" onClick={handleViewInterfaceOutline}>查看界面轮廓</span>。
                            </p>
                            <Button icon={<PlusOutlined className="common-record-span" />} className="ipm-add-btn" onClick={handleAdd}>添加界面</Button>
                        </div>

                        {tableData && Array.isArray(tableData) && tableData.length > 0 ? (
                            <div className="flex-wrap">
                                {tableData.map((item, index) => {
                                    return (
                                        <div key={index} className="ipm-menu-item" onClick={() => handleInterfaceParamsConfig(item)}>
                                            <p className="ipm-menu-icon flex-between-center">
                                                <span
                                                    className="flex-center"
                                                    style={{ backgroundColor: item?.shortcutKey || 'var(--main-bg)' }}
                                                >
                                                    {item.image ? iconBC(item.image) : <BulbOutlined />}
                                                </span>
                                                <Dropdown
                                                    menu={{
                                                        items: [{
                                                            key: '1',
                                                            label: (
                                                                <span
                                                                    style={{ minWidth: '100px' }}
                                                                    className="flex-align-items"
                                                                    onClick={(e) => handleCompile(item, e)}
                                                                >
                                                                    <EditOutlined style={{ marginRight: '6px' }} className="common-record-span" />
                                                                    编辑
                                                                </span>
                                                            ),
                                                        }, {
                                                            key: '2',
                                                            label: (
                                                                <Popconfirm
                                                                    title="删除后不可恢复，确定要删除吗?"
                                                                    onConfirm={(e) => handleDelete(item, e)}
                                                                    onClick={e => React.$stopPropagation(e)}
                                                                >
                                                                    <span style={{ minWidth: '100px' }} className="flex-align-items">
                                                                        <DeleteOutlined style={{ marginRight: '6px' }} className="common-record-delete-span" />
                                                                        删除
                                                                    </span>
                                                                </Popconfirm>
                                                            ),
                                                        }]
                                                    }}
                                                >
                                                    <span className="ipm-menu-icon-ellipsis" onClick={e => React.$stopPropagation(e)}>
                                                        <EllipsisOutlined style={{ fontSize: '20px' }} />
                                                    </span>
                                                </Dropdown>
                                            </p>
                                            <p className="ipm-menu-title">
                                                {item?.descripts || ''}
                                            </p>
                                            <p className="ipm-menu-doubt">
                                                {item?.tooltip || '这个人很懒，没有留下界面描述'}
                                            </p>
                                        </div>
                                    )
                                })}
                            </div>
                        ) : (
                            <div className="flex-justify-center">
                                <Empty style={{ marginTop: '200px' }} description="您还没有配置这类型的菜单，快去配置吧" image={Empty.PRESENTED_IMAGE_SIMPLE} />
                            </div>
                        )}
                    </div>
                    {dataGroupFlag && <div className="common-card-left-split-line"></div>}
                </div>
            </div>

            {/* 图片预览 */}
            <PublicImagePreview title="查看界面轮廓" ref={imagePreviewRef} />

            {/* 新增/编辑 */}
            <PublicDrawerFormHook
                title="添加界面"
                idField="menuDetailID"
                componentName="InterfaceParameterMaintenance"
                selectData={{ interfaceTypeData }}
                rowData={drawerRowData}
                ref={drawerFormRef}
                handleSave={handleAddSave}
            />

            {/* 参数配置 */}
            <SingleTableParamsConfig selectData={{ ...selectData, interfaceTypeData }} ref={singleConfigRef} />

            {/* 多级字典维护 */}
            <UniversalDictionaryParamsConfig selectData={{ ...selectData, interfaceTypeData }} ref={universalDictionaryConfigRef} />
        </div>
    );
};

export default InterfaceParameterMaintenance;