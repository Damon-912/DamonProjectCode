/*
 * Create:      柿子
 * CreateDate:  2023/04/28
 * Describe：   react组件 -- 组件数据维护
 * */
import React, { useEffect, useState, useRef } from 'react';
import { Row, Col, Input, Select, Button, message, Card, Tabs } from 'antd';
import { ProductOutlined } from '@ant-design/icons';
import { useLocation } from 'react-router-dom';
import { Util } from '@tools';
import { fieldFormData, colFormData } from './js/staticData';
import request from '@api';
import store from '@store';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import CDMComponentMaintenance from './component/CDMComponentMaintenance';
import './style/index.less';

const { Option } = Select;

const ComponentDataMaintenance = (props) => {
    const formData = [{
        dataIndex: 'code',
        title: '代码',
        typeCode: 'Input'
    }, {
        dataIndex: 'descripts',
        title: '描述',
        typeCode: 'Input',
        required: 'Y'
    }, {
        dataIndex: 'enDesc',
        title: '英文描述',
        typeCode: 'TextArea'
    }, {
        dataIndex: 'path',
        title: '路径',
        typeCode: 'TextArea'
    }, {
        dataIndex: 'comAddress',
        title: '组件地址',
        typeCode: 'TextArea'
    }, {
        dataIndex: 'note',
        title: '备注',
        typeCode: 'TextArea'
    }];

    let formRef = useRef(null);
    let location = useLocation();
    const { contentHeight } = store.getState();
    const [categoryData, setCategoryData] = useState({});
    const [selectData, setSelectData] = useState({});
    const [code, setCode] = useState(undefined);
    const [descripts, setDescripts] = useState(undefined);
    const [statusID, setStatusID] = useState(undefined);
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(20);
    const [columns, setColumns] = useState([]);
    const [totalWidth, setTotalWidth] = useState(0);
    const [loading, setLoading] = useState(false);
    const [tableData, setTableData] = useState([]);
    const [total, setTotal] = useState(0);
    const [rowID, setRowID] = useState('');
    const [rowData, setRowData] = useState({});
    const [activeTabPaneKey, setActiveTabPaneKey] = useState('1');
    const [componentColumns, setComponentColumns] = useState([]);
    const [componentTotalWidth, setComponentTotalWidth] = useState(0);
    const [componentFormData, setComponentFormData] = useState([]);
    // 国际化
    const [languageTotalWidth, setLanguageTotalWidth] = useState(0);
    const [languageColumns, setLanguageColumns] = useState([]);
    const [languageFormData, setLanguageFormData] = useState([]);
    // form表单数据维护
    const [formColumnTotalWidth, setFormColumnTotalWidth] = useState(0);
    const [formColumns, setFormColumns] = useState([]);
    const [formColumnFormData, setFormColumnFormData] = useState([]);
    // 操作按钮维护
    const [btnFormData, setBtnFormData] = useState([]);
    const [btnTotalWidth, setBtnTotalWidth] = useState(0);
    const [btnColumns, setBtnColumns] = useState([]);

    useEffect(() => {
        let newCategory;
        if ('paras' in props && props.paras && props.paras.params) { // 侧菜单获取类别参数
            newCategory = props.paras.params;
        } else {
            if (location && location.state && location.state.params) { // 头菜单获取类别参数
                newCategory = location.state.params;
                React.$setSessionData('ComponentDataMaintenance', newCategory, false);
            } else { // 头菜单刷新界面时获取类别
                newCategory = React.$getSessionData('ComponentDataMaintenance', false);
            }
        };
        let categoryData = Util.getObjByUrlStr(newCategory);
        console.log("ComponentDataMaintenance", categoryData);
        setCategoryData(categoryData);
        getColumnsData();
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

    // 获取列表表头数据
    const getColumnsData = async () => {
        try {
            const res = await request.getComponentInfo('ComponentDataMaintenance');
            setColumns(res.result?.C || []);
            setTotalWidth(res?.totalWidth || 0);
        } catch (error) {
            console.log(error);
        };
    };

    // 查询
    const handleQuery = () => {
        if (page === 1) {
            getTableData();
        } else {
            setPage(1);
        }
    };

    // 获取列表数据
    const getTableData = async () => {
        try {
            setLoading(true);
            let data = {
                params: [{
                    code,
                    descripts,
                    status: statusID
                }],
                pagination: [{
                    pageSize: pageSize,
                    currentPage: page,
                    sortColumn: '',
                    sortOrder: ''
                }]
            };
            const res = await React.$asyncPost('01010022', data);
            setTableData(React.$processingTableRequestData(res));
            setTotal(res.result?.total || 0);
            setLoading(false);
        } catch (error) {
            console.log(error);
            setLoading(false);
        };
    };

    // 数据导入
    const handleDataImport = () => {
        message.info('功能开发中……')
    };

    // 操作行
    const handleRowClick = (record) => {
        return {
            // 单击行选中
            onClick: () => {
                if (rowID === '' || (rowID && rowID !== record.id)) {
                    setRowID(record.id);
                    setRowData(record);
                } else {
                    setRowID('');
                    setRowData({});
                }
            }
        }
    };

    // 选中行操作
    const setRowClassName = (record) => {
        return record.id === rowID ? 'common-table-select-bg' : '';
    };

    // 切换医嘱查询页签
    const handleTabChange = key => {
        setActiveTabPaneKey(key);
    };

    useEffect(() => {
        if (activeTabPaneKey === '2') {
            componentColumns && componentColumns.length > 0 ? '' : getComponentColumns(); // 获取组件表列表头数据
            componentFormData && componentFormData.length > 0 ? '' : getComponentFormData(); // 获取组件表列按钮维护form数据
        } else if (activeTabPaneKey === '3') {
            languageColumns && languageColumns.length > 0 ? '' : getLanguageColumns(); // 获取国际化表头数据
            languageFormData && languageFormData.length > 0 ? '' : getLanguageFormData(); // 获取国际化form数据
        } else if (activeTabPaneKey === '4') {
            formColumns && formColumns.length > 0 ? '' : getFormColumns(); // 获取组件表列表头数据
            formColumnFormData && formColumnFormData.length > 0 ? '' : getFormColumnFormData(); // 获取组件表列按钮维护form数据
        } else if (activeTabPaneKey === '5') {
            btnColumns && btnColumns.length > 0 ? '' : getBtnColumns(); // 获取组件表列表头数据
            btnFormData && btnFormData.length > 0 ? '' : getBtnFormData(); // 获取组件表列按钮维护form数据
        }
    }, [activeTabPaneKey])

    // 保存
    const handleSave = async () => {
        try {
            let values = await formRef.current.handleSave('Y');
            let data = {
                params: [{
                    ...values,
                    id: rowID ? rowID : undefined,
                }]
            }
            const res = await React.$asyncPost('01010021', data);
            message.success(res?.errorMessage || '保存成功');
            setRowData(values);
            getTableData();
        } catch (error) {
            console.log(error);
        }
    };

    // 重置表单
    const resetFields = () => {
        if (rowID) {
            setRowID('');
        };
        setRowData({});
        formRef && formRef.current && formRef.current?.resetFields();
    };

    // 获取组件表列表头数据
    const getComponentColumns = () => {
        let componentColumns = [{
            key: 5,
            title: '序号',
            dataIndex: 'seqNo',
            align: 'center',
            width: '80px'
        }, {
            key: 1,
            title: '代码',
            dataIndex: 'code',
            align: 'center',
            width: '150px'
        }, {
            key: 2,
            title: '描述',
            dataIndex: 'descripts',
            align: 'center',
            width: '150px'
        }, {
            key: 3,
            title: '读写类型',
            dataIndex: 'type',
            align: 'center',
            width: '80px',
            render(text) {
                let config = {
                    'C': '列',
                    'B': '按钮'
                }
                return config[text];
            }
        }, {
            key: 4,
            title: '列宽',
            dataIndex: 'width',
            align: 'center',
            width: '80px'
        }, {
            key: 6,
            title: '显示',
            dataIndex: 'display',
            align: 'center',
            width: '80px',
        }, {
            key: 7,
            title: '打印',
            dataIndex: 'print',
            align: 'center',
            width: '80px',
        }, {
            key: 8,
            title: '导出',
            dataIndex: 'export',
            align: 'center',
            width: '80px',
        }, {
            key: 9,
            title: '关联方法',
            dataIndex: 'linkMethod',
            align: 'center',
            width: '100px'
        }, {
            key: 10,
            title: '关联服务',
            dataIndex: 'linkService',
            align: 'center',
            width: '100px'
        }, {
            key: 'fieldTypeDesc',
            title: '字段类型',
            dataIndex: 'fieldTypeDesc',
            align: 'center',
            width: '100px'
        }, {
            key: 'doubt',
            title: '字段描述',
            dataIndex: 'doubt',
            align: 'center',
            width: '100px'
        }, {
            key: 'params',
            title: '参数',
            dataIndex: 'params',
            align: 'center',
            width: '200px'
        }, {
            key: 11,
            title: '对齐方式',
            dataIndex: 'align',
            align: 'center',
            width: '80px',
            render(text) {
                let config = {
                    'left': '居左',
                    'center': '居中',
                    'right': '居右'
                }
                return config[text];
            }
        }, {
            key: 12,
            title: '固定显示',
            dataIndex: 'fixed',
            align: 'center',
            width: '80px',
            render(text) {
                let config = {
                    'left': '居左',
                    'right': '居右'
                }
                return config[text];
            }
        }, {
            key: 13,
            title: '是否显示标题',
            dataIndex: 'visible',
            align: 'center',
            width: '120px',
        }, {
            key: 14,
            title: '英文描述',
            dataIndex: 'enDesc',
            align: 'center',
            width: '200px'
        }];
        setComponentColumns(componentColumns);
        setComponentTotalWidth(1850);
    }

    // 获取组件表列按钮维护form数据
    const getComponentFormData = async () => {
        const nComponentFormData = [...colFormData];
        setComponentFormData(nComponentFormData);
    };

    // 获取table组件表单数据
    const getLanguageColumns = () => {
        let languageColumns = [{
            key: 1,
            title: '代码',
            dataIndex: 'code',
            align: 'center',
            width: '100px'
        }, {
            key: 2,
            title: '描述',
            dataIndex: 'descripts',
            align: 'center',
            width: '100px'
        }, {
            key: 4,
            title: '英文描述',
            dataIndex: 'enDesc',
            align: 'center',
            width: '100px'
        }, {
            key: 5,
            title: '提示信息',
            dataIndex: 'message',
            align: 'center',
            width: '100px'
        }, {
            key: 6,
            title: '提示信息英文',
            dataIndex: 'messageEN',
            align: 'center',
            width: '150px'
        }, {
            key: 7,
            title: '字段类型',
            dataIndex: 'fieldTypeDrDesc',
            align: 'center',
            width: '100px'
        }, {
            key: 8,
            title: '长度',
            dataIndex: 'length',
            align: 'center',
            width: '100px'
        }, {
            key: 9,
            title: '焦点顺序',
            dataIndex: 'focusIndex',
            align: 'center',
            width: '100px'
        }, {
            key: 10,
            title: '前缀',
            dataIndex: 'suffix',
            align: 'center',
            width: '100px'
        }, {
            key: 11,
            title: '是否必填',
            dataIndex: 'required',
            align: 'center',
            width: '80px'
        }, {
            key: 12,
            title: '是否无效',
            dataIndex: 'disabled',
            align: 'center',
            width: '80px'
        }];
        setLanguageColumns(languageColumns);
    };

    // 获取国际化表单数据
    const getLanguageFormData = () => {
        let languageFormData = [{
            dataIndex: 'CardTitle1',
            title: '基础信息配置',
            typeCode: 'CardTitle'
        }, {
            dataIndex: 'seqNo',
            title: '序号',
            typeCode: 'Input'
        }, {
            dataIndex: 'code',
            title: '代码',
            typeCode: 'Input',
            required: 'Y'
        }, {
            dataIndex: 'descripts',
            title: '描述',
            typeCode: 'Input',
            required: 'Y'
        }, {
            dataIndex: 'enDesc',
            title: '英文描述',
            typeCode: 'Input'
        }, {
            dataIndex: 'message',
            title: '提示信息',
            typeCode: 'Input'
        }, {
            dataIndex: 'messageEN',
            title: '提示信息英文',
            typeCode: 'Input'
        }, {
            dataIndex: 'CardTitle2',
            title: '操作配置',
            typeCode: 'CardTitle'
        }, {
            dataIndex: 'focusIndex',
            title: '焦点顺序',
            typeCode: 'Input'
        }, {
            dataIndex: 'fieldTypeID',
            title: '字段类型',
            typeCode: 'Select',
            className: 'fieldTypeList',
            defaultValue: ''
        }, {
            dataIndex: 'CardTitle3',
            title: '显示方式配置',
            typeCode: 'CardTitle'
        }, {
            dataIndex: 'suffix',
            title: '前缀',
            typeCode: 'Input'
        }, {
            dataIndex: 'length',
            title: '占位长度',
            typeCode: 'Input',
            defaultValue: 12
        }, {
            dataIndex: 'CardTitle4',
            title: '其他信息配置',
            typeCode: 'CardTitle'
        }, {
            dataIndex: 'required',
            title: '是否必填',
            typeCode: 'Switch'
        }, {
            dataIndex: 'disabled',
            title: '是否无效',
            typeCode: 'Switch'
        }];
        setLanguageFormData(languageFormData);
    };

    // 获取组件form表单字段表头数据
    const getFormColumns = () => {
        let formColumns = [{
            key: 1,
            title: '序号',
            dataIndex: 'seqNo',
            align: 'center',
            width: '60px'
        }, {
            key: 2,
            title: '代码',
            dataIndex: 'code',
            align: 'center',
            width: '180px'
        }, {
            key: 3,
            title: '描述',
            dataIndex: 'descripts',
            align: 'center',
            width: '180px'
        }, {
            key: 4,
            title: '英文描述',
            dataIndex: 'enDesc',
            align: 'center',
            width: '100px',
        }, {
            key: 5,
            title: '字段类型',
            dataIndex: 'fieldTypeDrDesc',
            align: 'center',
            width: '150px'
        }, {
            key: 6,
            title: '回调方法',
            dataIndex: 'callback',
            align: 'center',
            width: '100px'
        }, {
            key: 7,
            title: '提示信息',
            dataIndex: 'placeholder',
            align: 'center',
            width: '400px',
        }, {
            key: 8,
            title: '输入域描述',
            dataIndex: 'doubt',
            align: 'center',
            width: '500px',
        }, {
            key: 'customDataDesc',
            title: '数据集',
            dataIndex: 'customDataDesc',
            align: 'center',
            width: '150px'
        }, {
            key: 'customDataStr',
            title: '自定义数据集',
            dataIndex: 'customDataStr',
            align: 'center',
            width: '250px'
        }, {
            key: 9,
            title: '关联类',
            dataIndex: 'className',
            align: 'center',
            width: '150px'
        }, {
            key: 10,
            title: '关联方法',
            dataIndex: 'methodName',
            align: 'center',
            width: '150px'
        }, {
            key: 11,
            title: '关联取值',
            dataIndex: 'linkValueDesc',
            align: 'center',
            width: '150px'
        }, {
            key: 12,
            title: '取值接口代码',
            dataIndex: 'linkCode',
            align: 'center',
            width: '150px'
        }, {
            key: 14,
            title: '跳转到',
            dataIndex: 'jumpDesc',
            align: 'center',
            width: '100px'
        }, {
            key: 15,
            title: '默认值',
            dataIndex: 'default',
            align: 'center',
            width: '150px'
        }, {
            key: 'params',
            title: '参数',
            dataIndex: 'params',
            align: 'center',
            width: '300px'
        }, {
            key: 13,
            title: '占位',
            dataIndex: 'col',
            align: 'center',
            width: '100px'
        }, {
            key: 16,
            title: 'labelCol',
            dataIndex: 'labelCol',
            align: 'center',
            width: '100px'
        }, {
            key: 17,
            title: 'wrapperCol',
            dataIndex: 'wrapperCol',
            align: 'center',
            width: '100px'
        }, {
            key: 18,
            title: '是否必填',
            dataIndex: 'required',
            align: 'center',
            width: '80px',
        }, {
            key: 19,
            title: '是否只读',
            dataIndex: 'disabled',
            align: 'center',
            width: '80px',
        }, {
            key: 20,
            title: '是否显示',
            dataIndex: 'display',
            align: 'center',
            width: '80px',
        }];
        setFormColumns(formColumns);
        setFormColumnTotalWidth(1280);
    };

    // 获取组件form表单字段form数据
    const getFormColumnFormData = async () => {
        let addFormMode = categoryData?.addFormMode || 'modalSelect';
        let formColumnFormData = [];
        if (addFormMode === 'modalSelect') {
            formColumnFormData = [...fieldFormData];
        } else {
            formColumnFormData = [{
                dataIndex: 'code',
                title: '代码',
                typeCode: 'Input',
                required: 'Y',
                doubt: '表单保存时对应传给后台的字段（dataIndex）'
            }, {
                dataIndex: 'descripts',
                title: '描述',
                typeCode: 'Input',
                required: 'Y',
                doubt: '表单对应的描述'
            }, {
                dataIndex: 'seqNo',
                title: '序号',
                typeCode: 'Input'
            }, {
                dataIndex: 'enDesc',
                title: '英文描述',
                typeCode: 'Input'
            }, {
                dataIndex: 'fieldTypeID',
                title: '字段类型',
                typeCode: 'Select',
                className: 'fieldTypeList',
                defaultValue: '5'
            }, {
                dataIndex: 'callback',
                title: '回调方法',
                typeCode: 'Input'
            }, {
                dataIndex: 'placeholder',
                title: '提示信息',
                typeCode: 'Input',
                doubt: '操作框对应的placeholder'
            }, {
                dataIndex: 'doubt',
                title: '输入域描述',
                typeCode: 'Input',
                doubt: '补充说明该字段的含义，指引用户正确填写该字段'
            }, {
                dataIndex: 'customDataID',
                title: '数据集',
                typeCode: 'Select',
                className: 'customDataSet',
                doubt: '针对于选择框绑定的数据源',
                disabled: 'Y'
            }, {
                dataIndex: 'customDataStr',
                title: '自定义数据集',
                typeCode: 'TextArea',
                doubt: '如果同时维护了数据集和自定义数据集，优先展示数据集关联的数据',
                placeholder: 'key:value形式，可维护多个数据，多个用 & 拼接 [栗:   all:全部&Y:生效&N:失效]',
                disabled: 'Y'
            }, {
                dataIndex: 'className',
                title: '关联类',
                typeCode: 'Input',
                doubt: '可维护成下拉框数据对应初始化接口的字段名；或下拉列表/远程搜索对应的接口代码；或维护成disabledDate，可以控制日期选择范围'
            }, {
                dataIndex: 'methodName',
                title: '关联方法',
                typeCode: 'Input',
                doubt: '可维护下拉列表请求接口对应的别名字段及远程搜索后台对应接收的ID字段；当className=disabledDate时可对应维护成 <，<=，>，>='
            }, {
                dataIndex: 'linkValueID',
                title: '关联取值',
                typeCode: 'Select',
                mode: 'multiple',
                detailItem: [],
                doubt: '下一个下拉框需要根据当前选择的值获取数据（比如选择省去获取市的数据）'
            }, {
                dataIndex: 'linkCode',
                title: '取值接口代码',
                typeCode: 'Input',
                doubt: '关联取值对应的接口代码/为远程搜索时需维护成数据查询接口后台接收字段（入：desc）'
            }, {
                dataIndex: 'jumpID',
                title: '跳转到',
                typeCode: 'Select',
                doubt: '回车后希望跳转到哪一个输入域？？？跳转到下一个可不用维护，默认下一个。'
            }, {
                dataIndex: 'col',
                title: '占位',
                typeCode: 'Input',
                defaultValue: 12,
                doubt: '一行24份，独占一行则维护24，一行两个则维护12，以此类推'
            }, {
                dataIndex: 'labelCol',
                title: 'labelCol',
                typeCode: 'Input',
                defaultValue: 8,
                doubt: 'label对应的份数（共24份）'
            }, {
                dataIndex: 'wrapperCol',
                title: 'wrapperCol',
                typeCode: 'Input',
                defaultValue: 16,
                doubt: '操作框对应的份数（共24份）小技巧分享：希望买个formItem存在间隙的话wrapperCol可以少占一份'
            }, {
                dataIndex: 'default',
                title: '默认值',
                typeCode: 'Input',
                doubt: '日期组件可以维护1/2/3，默认第前几天(0是当前)，Switch可以维护Y/N'
            }, {
                dataIndex: 'params',
                title: '参数',
                typeCode: 'Input',
                doubt: '其他不固定的参数可维护在这[栗子：flag:Y&hidden:N]'
            }, {
                dataIndex: 'required',
                title: '是否必填',
                typeCode: 'Switch'
            }, {
                dataIndex: 'disabled',
                title: '是否只读',
                typeCode: 'Switch'
            }, {
                dataIndex: 'display',
                title: '是否显示',
                typeCode: 'Switch',
                defaultValue: 'Y'
            }];
        }
        setFormColumnFormData(formColumnFormData)
    };

    useEffect(() => {
        getTableData();
    }, [page, pageSize]);

    // 提供修改page和pageSize的回调函数
    const handlePaginationChange = (page, pageSize) => {
        setPage(page);
        setPageSize(pageSize);
    };

    // 获取操作按钮表头数据
    const getBtnColumns = () => {
        let btnColumns = [{
            key: 'code',
            dataIndex: 'code',
            title: '代码',
            align: 'center',
            width: '100px'
        }, {
            key: 1,
            title: '描述',
            dataIndex: 'title',
            align: 'center',
            width: '100px'
        }, {
            key: 2,
            title: '图标',
            dataIndex: 'icon',
            align: 'center',
            width: '100px'
        }, {
            key: 3,
            title: '点击事件',
            dataIndex: 'onClick',
            align: 'center',
            width: '100px'
        }, {
            key: 4,
            title: '类型',
            dataIndex: 'typeDesc',
            align: 'center',
            width: '100px',
        }, {
            key: 5,
            title: '按钮大小',
            dataIndex: 'sizeDesc',
            align: 'center',
            width: '100px',
        }, {
            key: 6,
            title: '按钮形状',
            dataIndex: 'shapeDesc',
            align: 'center',
            width: '150px',
        }, {
            key: 7,
            title: '跳转地址',
            dataIndex: 'href',
            align: 'center',
            width: '100px'
        }, {
            key: 8,
            title: 'target属性',
            dataIndex: 'target',
            align: 'center',
            width: '100px'
        }, {
            key: 9,
            title: '背景透明',
            dataIndex: 'ghost',
            align: 'center',
            width: '100px',
        }, {
            key: 10,
            title: '宽度自适应',
            dataIndex: 'block',
            align: 'center',
            width: '100px',
        }];
        setBtnColumns(btnColumns);
        setBtnTotalWidth(1280);
    }

    // 获取操作按钮form数据
    const getBtnFormData = () => {
        let btnFormData = [{
            dataIndex: 'CardTitle1',
            title: '基础信息配置',
            typeCode: 'CardTitle'
        }, {
            dataIndex: 'code',
            title: '代码',
            typeCode: 'Input',
            required: 'Y'
        }, {
            dataIndex: 'title',
            title: '描述',
            typeCode: 'Input',
            required: 'Y'
        }, {
            dataIndex: 'icon',
            title: '图标',
            typeCode: 'Input',
            placeholder: '对应antd/Icon组件名称',
            doubt: '设置按钮的图标类型'
        }, {
            dataIndex: 'CardTitle2',
            title: '按钮属性配置',
            typeCode: 'CardTitle'
        }, {
            dataIndex: 'typeID',
            title: '类型',
            typeCode: 'Select',
            doubt: '设置按钮类型，可选值为 primary dashed danger link(3.17 中增加) 或者不设，默认为default',
            className: 'btnTypeList',
        }, {
            dataIndex: 'sizeID',
            title: '按钮大小',
            typeCode: 'Select',
            doubt: '设置按钮大小，可选值为 small large 或者不设',
            className: 'btnSizeList',
        }, {
            dataIndex: 'shapeID',
            title: '按钮形状',
            typeCode: 'Select',
            doubt: '设置按钮形状，可选值为 circle、 round 或者不设',
            className: 'btnShapeList',
        }, {
            dataIndex: 'target',
            title: 'target 属性',
            typeCode: 'Input',
            doubt: '相当于 a 链接的 target 属性，href 存在时生效'
        }, {
            dataIndex: 'ghost',
            title: '背景透明',
            typeCode: 'Switch',
            doubt: '幽灵属性，使按钮背景透明'
        }, {
            dataIndex: 'block',
            title: '宽度自适应',
            typeCode: 'Switch',
            doubt: '将按钮宽度调整为其父宽度的选项'
        }, {
            dataIndex: 'CardTitle2',
            title: '事件绑定',
            typeCode: 'CardTitle'
        }, {
            dataIndex: 'href',
            title: '跳转地址',
            typeCode: 'Input',
            doubt: '点击跳转的地址，指定此属性 button 的行为和 a 链接一致'
        }, {
            dataIndex: 'onClick',
            title: '点击事件',
            typeCode: 'Input',
            doubt: '点击按钮时的回调'
        }];
        setBtnFormData(btnFormData);
    };

    return (
        <div className="component-data-maintenance">
            <Row className="common-query-header">
                <Col span={16}>
                    <div>
                        代码：<Input
                            value={code}
                            className="common-query-input"
                            title="输入内容后可回车检索"
                            placeholder="请输入( Enter )"
                            onChange={e => setCode(e.target.value)}
                            onPressEnter={handleQuery}
                        />
                        描述：<Input
                            value={descripts}
                            className="common-query-input"
                            title="输入内容后可回车检索"
                            placeholder="请输入( Enter )"
                            onChange={e => setDescripts(e.target.value)}
                            onPressEnter={handleQuery}
                        />
                        状态：<Select
                            allowClear
                            showSearch
                            value={statusID}
                            placeholder="请选择"
                            optionFilterProp="search"
                            className="common-query-input"
                            onChange={e => setStatusID(e)}
                        >
                            <Option value="">全部</Option>
                            <Option value="1">可用</Option>
                            <Option value="0">不可用</Option>
                        </Select>
                        <Button type="primary" loading={loading} onClick={handleQuery}>查询</Button>
                    </div>
                </Col>
                <Col span={8} className="flex-end-align-center">
                    <Button
                        ghost
                        type="primary"
                        style={{ width: '100px' }}
                        onClick={handleDataImport}
                    >
                        数据导入
                    </Button>
                </Col>
            </Row>
            <div className="common-query-split-line"></div>
            <Row>
                <Col span={10}>
                    <div style={{ paddingRight: '6px', position: 'relative' }}>
                        <Card
                            size="small"
                            bordered={false}
                            title={(
                                <div className="common-card-title-icon">
                                    <ProductOutlined />
                                    组件信息
                                </div>
                            )}
                            className="cdm-left-card"
                        >
                            <PublicTablePagination
                                param={{
                                    page, // 当前页数
                                    total, // 数据总条数
                                    loading,
                                    // 表头配置
                                    columns,
                                    defaultPageSize: 20,
                                    x: totalWidth, // 表格的宽度
                                    y: contentHeight - 209,
                                    height: contentHeight - 169 + 'px',
                                    data: tableData, // 表格数据
                                    componentName: 'ComponentDataMaintenance',
                                }}
                                compilePage={handlePaginationChange}
                                getColumns={getColumnsData}
                                onRow={handleRowClick}
                                rowClassName={setRowClassName}
                            />
                        </Card>
                        <div className="common-card-right-split-line"></div>
                    </div>
                </Col>
                <Col span={14} style={{ padding: '0 12px' }}>
                    <Tabs
                        items={[{
                            key: '1',
                            label: '基本信息',
                            children: (
                                <div style={{ padding: '12px', height: contentHeight - 142 + 'px', overflow: 'auto' }}>
                                    <DynamicRenderingForm
                                        ref={formRef}
                                        formItemCol={{ labelCol: 3, wrapperCol: 10, col: 24 }}
                                        rowData={rowData}
                                        formData={formData}
                                    />
                                    <Row style={{ marginTop: '12px' }}>
                                        <Col span={3}></Col>
                                        <Col span={12}>
                                            <Button type='primary' onClick={handleSave}>{rowID ? '确认修改' : '保存'}</Button>
                                            <Button style={{ marginLeft: '24px' }} onClick={resetFields}>{rowID ? '取消修改' : '重置'}</Button>
                                        </Col>
                                    </Row>
                                </div>
                            ),
                        }, {
                            key: '2',
                            label: '组件列维护',
                            children: (
                                <CDMComponentMaintenance
                                    type="table"
                                    saveCode="01010023"
                                    deleteCode="01010029"
                                    queryCode="01010024"
                                    componentTitle="组件表列维护"
                                    className="User.CBReactComTable"
                                    componentID={rowID}
                                    selectData={selectData}
                                    columns={componentColumns}
                                    totalWidth={componentTotalWidth}
                                    formData={componentFormData}
                                />
                            )
                        }, {
                            key: '3',
                            label: '中英文国际化',
                            children: (
                                <CDMComponentMaintenance
                                    type="field"
                                    saveCode="01010025"
                                    deleteCode="01010030"
                                    queryCode="01010026"
                                    componentTitle="国际化数据维护"
                                    componentID={rowID}
                                    selectData={selectData}
                                    columns={languageColumns}
                                    formData={languageFormData}
                                    totalWidth={languageTotalWidth}
                                />
                            )
                        }, {
                            key: '4',
                            label: '表单元素维护',
                            children: (
                                <CDMComponentMaintenance
                                    type="form"
                                    saveCode="01010044"
                                    deleteCode="01010048"
                                    queryCode="01010045"
                                    addMode={categoryData?.addFormMode || 'modalSelect'}
                                    componentTitle="Form表单元素"
                                    className="User.CBReactForm"
                                    modalTitle="字段选择"
                                    modalWidth="1000px"
                                    modalSelectCode="01010050"
                                    modalTableHeight={450}
                                    modalComponentName="FieldManagement"
                                    modalQueryCode="01010042"
                                    modalPaginationFlag="Y"
                                    componentID={rowID}
                                    columns={formColumns}
                                    selectData={selectData}
                                    formData={formColumnFormData}
                                    totalWidth={formColumnTotalWidth}
                                />
                            )
                        }, {
                            key: '5',
                            label: '按钮维护',
                            children: (
                                <CDMComponentMaintenance
                                    type="button"
                                    saveCode="01010046"
                                    deleteCode="01010049"
                                    queryCode="01010047"
                                    componentTitle="操作按钮维护"
                                    componentID={rowID}
                                    selectData={selectData}
                                    columns={btnColumns}
                                    formData={btnFormData}
                                    totalWidth={btnTotalWidth}
                                />
                            )
                        }]}
                        activeKey={activeTabPaneKey}
                        onChange={handleTabChange}
                    />
                </Col>
            </Row>
        </div>
    )
};

export default ComponentDataMaintenance;