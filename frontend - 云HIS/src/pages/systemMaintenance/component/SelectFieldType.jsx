/*
 * Create:      柿子
 * CreateDate:  2024/05/14
 * Describe：   选择需要添加的字段类型
 * */
import React, { useState, useEffect, forwardRef, useImperativeHandle } from 'react';
import { Modal, Row, Col, Anchor, message } from 'antd';
import '../style/children.less';

const SelectFieldType = (props, ref) => {
    const [visible, setVisible] = useState(false);
    const [imageUrls, setImageUrls] = useState({});
    const [anchorActive, setAnchorActive] = useState({});
    const anchorList = [{
        key: '1',
        id: 'af-input',
        href: '#af-input',
        title: '输入框',
        detailItem: [{
            key: '1-1',
            title: '单行输入框',
            typeCode: 'Input',
            describe: '可自由填写的文本，适用于单行场景',
            image: 'single-input'
        }, {
            key: '1-2',
            title: '多行输入框',
            typeCode: 'TextArea',
            describe: '可自由填写数字，附带快速增减按钮',
            image: 'multi-input'
        }, {
            key: '1-3',
            title: '数字输入框',
            typeCode: 'InputNumber',
            describe: '可自由填写的文本，适用于单行场景',
            image: 'number'
        }]
    }, {
        key: '2',
        id: 'af-select',
        href: '#af-select',
        title: '下拉框',
        detailItem: [{
            key: '2-1',
            title: '下拉框',
            typeCode: 'Select',
            describe: '提供一组选项列表来选择其中的一个项目',
            image: 'vote-option'
        }, {
            key: '2-2',
            title: '多选下拉框',
            typeCode: 'SelectBox',
            describe: '提供一组选项列表来选择其中的一个或多个项目',
            image: 'vote-option-multi'
        }, {
            key: '2-3',
            title: '下拉树单选',
            typeCode: 'TreeSelect',
            describe: '提供一组树选项列表来选择其中的一个',
            image: 'select'
        }, {
            key: '2-4',
            title: '下拉树多选',
            typeCode: 'TreeSelectCheck',
            describe: '提供一组树选项列表来选择其中的一个或多个项目',
            image: 'tree-multi-select'
        }]
    }, {
        key: '3',
        id: 'af-check',
        href: '#af-check',
        title: '选择框',
        detailItem: [{
            key: '3-1',
            title: '单选框',
            typeCode: 'Radio',
            describe: '允许用户对需求一个选项操作',
            image: 'select'
        }, {
            key: '3-2',
            title: '多选框',
            typeCode: 'Checkbox',
            describe: '允许用户对需求一个或多个选项操作',
            image: 'vote-option-multi'
        }, {
            key: '3-3',
            title: '开关',
            typeCode: 'Switch',
            describe: '开关类型字段，提供是和否两种状态',
            image: 'bool'
        }]
    }, {
        title: '日期框',
        id: 'af-date',
        href: '#af-date',
        key: '4',
        detailItem: [{
            key: '4-1',
            title: '日期 + 时间',
            typeCode: 'DateTime',
            describe: '通过精确到秒的日期选择器选择某一天的具体时刻',
            image: 'date-precise'
        }, {
            key: '4-2',
            title: '日期',
            typeCode: 'Date',
            describe: '通过日期选择器选择某一天',
            image: 'date-no-precise'
        }, {
            key: '4-3',
            title: '时间',
            typeCode: 'Time',
            describe: '通过时间选择器选择时分秒',
            image: 'date-no-precise'
        }, {
            key: '4-4',
            title: '日期区间',
            typeCode: 'RangePicker',
            describe: '可以选择起止日期，用于排期等时间范围选择',
            image: 'schedule'
        }]
    }, {
        title: '文件上传',
        id: 'af-upload',
        href: '#af-upload',
        key: '5',
        detailItem: [{
            key: '5-1',
            title: '附件上传',
            typeCode: 'UploadFile',
            describe: '可上传保存一个或多个文件',
            image: 'multi-file'
        }, {
            key: '5-2',
            title: '图片上传',
            typeCode: 'UploadImg',
            describe: '可上传保存一个或多个文件',
            image: 'multi-file'
        }]
    }, {
        title: '其他',
        id: 'af-other',
        href: '#af-other',
        key: '6',
        detailItem: [{
            key: '6-1',
            title: '按钮',
            typeCode: 'Button',
            describe: '可在表单中随意位置插入一个按钮',
            image: 'link'
        }, {
            key: '6-2',
            title: '分割线',
            typeCode: 'Divider',
            describe: '可在表单中随意位置插入分割线',
            image: 'link'
        }, {
            key: '6-3',
            title: 'Card标题',
            typeCode: 'CardTitle',
            describe: '可在表单中随意位置插入一个标题',
            image: 'multi-signal'
        }, {
            key: '6-4',
            title: '占位符',
            typeCode: 'Occupy',
            describe: '可在表单中随意位置插入一个占位符',
            image: 'multi-signal'
        }]
    }];

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        setVisible
    }));

    const loadImage = async imageName => {
        const module = await import(`../images/${imageName}.png`);
        return module.default;
    };

    useEffect(() => {
        let activeFlag = true;
        anchorList && anchorList.forEach((item) => {
            let anchorDetailItem = item && 'detailItem' in item && item.detailItem && Array.isArray(item.detailItem) ? item.detailItem : [];
            if (anchorDetailItem && anchorDetailItem.length > 0) {
                if (activeFlag) { // 默认第一个 - 如果第一个没有子集默认第二个...
                    let firstAnchor = anchorDetailItem[0];
                    setAnchorActive(firstAnchor);
                }
                activeFlag = false;
                anchorDetailItem.forEach(async detailItem => {
                    if (detailItem.image) {
                        // 使用图片名称作为key值保存到state中。
                        const url = await loadImage(detailItem.image);
                        setImageUrls(prevState => ({ ...prevState, [detailItem.image]: url }));
                    }
                });
            }
        });
    }, []);

    // 确认
    const handleOk = () => {
        console.log('anchorActive', anchorActive)
        if (anchorActive && JSON.stringify(anchorActive) !== '{}') {
            props && 'handleOk' in props && props.handleOk(anchorActive);
            setVisible(false);
        } else {
            message.warning('请选择字段类型');
        }
    };

    // 选择类型
    const handleAnchorItemClick = (record) => {
        setAnchorActive(record);
    };

    // 需自定义锚点跳转，头菜单会跳转路由
    const handleAnchorClick = (e, link) => {
        console.log(link);
        e.preventDefault();
        // 这里的link参数包含了当前点击的锚点信息
        const element = document.getElementById(link.href.slice(1));
        if (element) {
            element.scrollIntoView({ behavior: 'smooth' });
        }
    };

    return (
        <Modal
            title="选择字段类型"
            okText="下一步"
            width="800px"
            className="select-field-type"
            open={visible}
            onOk={handleOk}
            onCancel={() => setVisible(false)}
        >
            <Row>
                <Col span={5}>
                    <Anchor
                        items={anchorList}
                        getContainer={() => document.getElementById('sft-right-card')}
                        onClick={handleAnchorClick}
                    />
                </Col>
                <Col span={19}>
                    <div id="sft-right-card" className="sft-right-card">
                        {anchorList && anchorList.map((item, index) => {
                            const detailItem = item?.detailItem || [];
                            return (
                                <div key={index} id={item?.id || ''} className="sft-right-card-item">
                                    <h3 className="sft-right-card-item-header">{item?.title || ''}</h3>
                                    <div className="flex-wrap">
                                        {detailItem && Array.isArray(detailItem) && detailItem.length > 0 && detailItem.map((detailItem, detailIndex) => {
                                            return (
                                                <div
                                                    key={'detail' + detailIndex}
                                                    className={['sft-right-card-item-content', anchorActive?.key === detailItem?.key ? 'sft-right-card-item-active' : ''].join(' ')}
                                                    onClick={() => handleAnchorItemClick(detailItem)}
                                                >
                                                    <div style={{ background: 'url(' + imageUrls[detailItem.image] + ') no-repeat' }} className="sft-right-card-item-img"></div>
                                                    <div style={{ padding: '6px 12px' }}>
                                                        <div className="sft-right-card-item-title">
                                                            {detailItem?.title || ''}
                                                        </div>
                                                        <div className="sft-right-card-item-describe">
                                                            {detailItem?.describe || ''}
                                                        </div>
                                                    </div>
                                                </div>
                                            )
                                        })}
                                    </div>
                                </div>
                            )
                        })}
                    </div>
                </Col>
            </Row>
        </Modal>
    )
};

export default forwardRef(SelectFieldType);