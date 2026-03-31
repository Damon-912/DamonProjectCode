import React, { useEffect, useRef, useState } from 'react';
import { Modal, Button } from 'antd';
import { BellOutlined } from '@ant-design/icons';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import PublicTablePagination from '@pages/common/PublicTablePagination';

const Test = () => {
    let formRef = useRef(null);
    const [formData, setFormData] = useState([]);
    const [rowData, setRowData] = useState({});
    const [selectData, setSelectData] = useState({});
    const [page, setPage] = useState(0);
    const [pageSize, setPageSize] = useState(0);
    const [total, setTotal] = useState(0);
    const [loading, setLoading] = useState(0);
    const [tableData, setTableData] = useState([]);
    const [totalWidth, setTotalWidth] = useState(0);
    const [columns, setColumns] = useState([]);

    useEffect(() => {
        getFormData();
        getSelectData();
    }, []);

    const getSelectData = () => {
        setTimeout(() => {
            let nSelectData = {
                select1: [{
                    id: '1',
                    descripts: 'option1-11111'
                }, {
                    id: '2',
                    descripts: 'option1-22222'
                }, {
                    id: '3',
                    descripts: 'option1-33333'
                }, {
                    id: '4',
                    descripts: 'option1-44444'
                }],
                select2: [{
                    id: '1',
                    descripts: 'option2-11111'
                }, {
                    id: '2',
                    descripts: 'option2-22222'
                }, {
                    id: '3',
                    descripts: 'option2-33333'
                }, {
                    id: '4',
                    descripts: 'option2-44444'
                }]
            }
            setSelectData(nSelectData);
        }, 1000 * 6)
    };

    const getFormData = () => {
        setTimeout(() => {
            const nFormData = [{
                dataIndex: 'code',
                title: '代码',
                typeCode: 'Input',
                required: 'Y',
                default: '测试123',
                width: '100px'
                // col: 24,
                // labelCol: 4,
                // wrapperCol: 18
            }, {
                dataIndex: 'descripts',
                title: '描述',
                typeCode: 'Input',
                required: 'Y',
                width: '100px'
                // col: 24,
                // labelCol: 4,
                // wrapperCol: 18
            }, {
                dataIndex: 'select1',
                title: '下拉框1',
                typeCode: 'Select',
                required: 'Y',
                className: 'select1',
                width: '200px'
                // col: 24,
                // labelCol: 4,
                // wrapperCol: 18
            }, {
                dataIndex: 'select2',
                title: '下拉框1',
                typeCode: 'Select',
                required: 'Y',
                className: 'select2',
                width: '200px'
                // col: 24,
                // labelCol: 4,
                // wrapperCol: 18
            }, {
                dataIndex: 'enDesc',
                title: '英文描述',
                typeCode: 'Input',
                width: '200px'
                // col: 24,
                // labelCol: 4,
                // wrapperCol: 18
            }, {
                dataIndex: 'path',
                title: '组件路径',
                typeCode: 'Input',
                width: '200px'
                // col: 24,
                // labelCol: 4,
                // wrapperCol: 18
            }, {
                dataIndex: 'startDate',
                title: '生效日期',
                required: 'Y',
                typeCode: 'Date',
                default: 0,
                // width: '100px'
                // col: 24,
                // labelCol: 4,
                // wrapperCol: 18
            }, {
                dataIndex: 'stopDate',
                title: '失效日期',
                // width: '100px',
                typeCode: 'Date',
                // col: 24,
                // labelCol: 4,
                // wrapperCol: 18
            }, {
                dataIndex: 'comAddress',
                title: '方法文件名',
                typeCode: 'Input',
                placeholder: '操作按钮事件对应的js文件名(默认使用当前组件名)',
                doubt: '对应的js文件统一放在当前组件js文件夹下',
                width: '200px'
                // col: 24,
                // labelCol: 4,
                // wrapperCol: 18
            }, {
                dataIndex: 'note',
                title: '备注',
                typeCode: 'Input',
                width: '200px'
                // col: 24,
                // labelCol: 4,
                // wrapperCol: 18
            }];
            setFormData(nFormData);
            setColumns(nFormData);
            setTotalWidth(1550);
        }, 1000)
    };

    // 保存
    const handleSave = async () => {
        let values = await formRef.current.handleSave();
        console.log(values);
    }

    // 重置
    const handleReset = async () => {
        if (rowData && JSON.stringify(rowData) !== '{}') {
            setRowData({});
        };
        formRef && formRef.current && formRef.current.resetFields();
        setTableData([]);
        setTotal(0);
    };

    const handleModify = () => {
        setRowData({
            code: 'cs123',
            descripts: '测试123',
            enDesc: 'test123',
            path: 'pages/home/index.jsx',
            note: '这是一个测试界面',
            startDate: '2024-01-12'
        });
    };

    // 登录
    const handleLogin = async () => {
        Modal.confirm({
            title: '版本更新提示',
            icon: <BellOutlined />,
            content: '发现系统版本更新，请刷新界面',
            okText: '确认刷新',
            cancelText: '稍后刷新',
            onOk: () => {
                window.location.reload();
            }
        });
        // try {
        //     let data = {
        //         params: [{
        //             username: '123',
        //         }]
        //     }
        //     const res = await React.$asyncPost('01010002', data)
        //     console.log(res)
        // } catch (error) {
        //     console.log(error);
        // }
    };

    useEffect(() => {
        getTableData();
    }, [page, pageSize]);

    const handlePaginationChange = (nPage, nPageSize) => {
        setPage(nPage);
        setPageSize(nPageSize);
    }

    // 查询
    const handleQuery = () => {
        if (page === 1) {
            getTableData();
        } else {
            setPage(1);
        }
    };

    const getTableData = () => {
        console.log('触发了查询')
        setLoading(true);
        setTimeout(() => {
            let nTableData = [];
            for (let i = 0; i < 10; i++) {
                nTableData.push({
                    key: i + 1,
                    code: '11' + '_' + i,
                    descripts: '测试11' + '_' + i,
                    enDesc: 'test11' + '_' + i,
                    path: 'pages/home/index.jsx',
                    note: '这是一个测试界面',
                    startDate: '2024-01-12'
                })
            }
            setTableData(nTableData);
            setTotal(nTableData.length);
            setLoading(false);
        }, 1000 * 5)
    };

    // 输入域change
    const handleInputChange = (val, index, dataIndex) => {
        setTableData(prevTableData => {
            let newTableData = [...prevTableData];
            if (newTableData[index]) {
                newTableData[index][dataIndex] = val;
            };
            return newTableData;
        });
    };

    return (
        <div>
            <h1>这是一个动态表单渲染示例</h1>
            <div>
                <DynamicRenderingForm
                    ref={formRef}
                    rowData={rowData}
                    formData={formData}
                    selectData={selectData}
                    formItemCol={{ col: 12, labelCol: 5, wrapperCol: 16 }}
                />
                <Button type="primary" onClick={handleSave}>保存</Button>
                <Button style={{ marginLeft: '12px' }} type="primary" onClick={handleModify}>修改</Button>
                <Button style={{ marginLeft: '12px' }} type="primary" onClick={handleQuery}>查询</Button>
                <Button style={{ marginLeft: '12px' }} type="dashed" onClick={handleReset}>重置</Button>
                <Button style={{ marginLeft: '12px' }} type="dashed" onClick={handleLogin}>请求接口</Button>
            </div>

            <PublicTablePagination
                param={{
                    page,
                    total,
                    loading,
                    columns,
                    selectData,
                    data: tableData,
                    x: totalWidth,
                    componentName: 'Test'
                }}
                getColumns={getFormData}
                compilePage={handlePaginationChange}
                onChange={handleInputChange}
            />
        </div>
    )
};

export default Test;