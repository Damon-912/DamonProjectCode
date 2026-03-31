import React, { useCallback } from 'react';
import { Tabs, Layout } from 'antd';
import { CloseOutlined } from '@ant-design/icons';
import Loading from '@components/loading';
import ErrorBoundary from '@routes/ErrorBoundary';
import * as Icon from '@ant-design/icons';

const { Content } = Layout;

const Breadcrumbs = (props) => {
    // 打开子窗口 - tab
    const openWindowBySubTab = useCallback((tab) => {
        props.addSubMenuTabData(tab);
    }, [props]);

    // 跳转指定标签页
    const setCurrentActiveKey = useCallback((activeKey) => {
        props.gotoMenuTabByActiveKey(activeKey);
    }, [props]);

    // 删除指定标签页
    const deleteSubMenuTabData = useCallback((targetKey, activeKey, e) => {
        e.stopPropagation();
        props.deleteSubMenuTabData(targetKey, activeKey);
    }, [props]);

    // 切换菜单，更改activeKey
    const handleChange = useCallback((activeKey) => {
        props.setActiveKey(activeKey);
    }, [props]);

    // 编辑操作，目前仅支持 remove
    const handleEdit = useCallback((targetKey, action) => {
        if (action === 'remove') {
            props.deleteSubMenuTabData(targetKey, props.activeKey);
        }
    }, [props]);

    // 动态创建图标组件
    const iconBC = useCallback((name) => React.createElement(Icon[name]), []);
    const { activeKey, tabs } = props;
    return (
        <div className="breadcrumb">
            <Tabs
                hideAdd
                className="breadcrumb-tabs"
                items={tabs && tabs.map((item, index) => {
                    const title = item?.label || item?.title || '';
                    const DynamicComponent = item?.component || null;
                    let interfaceMenuCode = item?.code || '';
                    let paramsStr = item?.paras?.params || item?.paras || '';
                    paramsStr = `${paramsStr}${paramsStr ? '&' : ''}interfaceMenuCode:${interfaceMenuCode}`; // 当前菜单代码
                    return {
                        key: title,
                        label: (
                            <div
                                className={`breadcrumb-box ${index === 0 ? 'breadcrumb-box-first' : ''}`}
                                style={{ color: item['color-disabled'] == 'true' ? 'var(--main-bg)' : '' }}
                            >
                                <span>{item.icon ? iconBC(item.icon) : ''}</span>
                                <span className="breadcrumbTitle" onClick={() => setCurrentActiveKey(title)}>
                                    {title}
                                </span>
                                {index != 0 ? <CloseOutlined onClick={(e) => deleteSubMenuTabData(title, '', e)} /> : ''}
                            </div>
                        ),
                        children: (
                            <Content className="breadcrumb-content">
                                <div style={{ background: '#fff', minHeight: 'calc(100vh - 100px)', overflowY: 'auto', position: 'relative', width: '100%' }}>
                                    {DynamicComponent === undefined ? '' : (
                                        <ErrorBoundary>
                                            <React.Suspense fallback={<Loading />}>
                                                <DynamicComponent
                                                    key={`${item?.code || String(index + 1)}-${title}`}
                                                    paras={{ params: paramsStr, menuCode: interfaceMenuCode }}
                                                    menuCode={item?.code || ''}
                                                    setCurrentActiveKey={setCurrentActiveKey}
                                                    openWindowBySubTab={openWindowBySubTab}
                                                    deleteSubMenuTabData={deleteSubMenuTabData}
                                                />
                                            </React.Suspense>
                                        </ErrorBoundary>
                                    )}
                                </div>
                            </Content>
                        ),
                    };
                })}
                activeKey={activeKey}
                onEdit={handleEdit}
                onChange={handleChange}
            ></Tabs>
        </div>
    )
};

export default Breadcrumbs;