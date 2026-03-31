/*
 * Create:      柿子
 * CreateDate:  2024/04/15
 * Describe：   表单渲染
 * */
import React, { useState, useEffect, forwardRef, useImperativeHandle, useCallback, useRef } from 'react';
import {
    Form, Row, Col, Input, Radio, Select, DatePicker, Switch, Checkbox, Tag, Upload, message, TimePicker, Cascader, Tooltip, Button, Divider, InputNumber, TreeSelect,
    ColorPicker, Image, Spin
} from 'antd';
import { LoadingOutlined, PlusOutlined, QuestionCircleOutlined, UploadOutlined } from '@ant-design/icons';
import { Util } from '@tools';
import { menuIcons } from '@tools/icon';
import { dayFormat, timeFormat, dateFormat } from '@tools/moment';
import { envConfig } from '@envConfig';
import * as Icon from '@ant-design/icons';
import dayjs from 'dayjs';
import './style/index.less';

const { RangePicker } = DatePicker;
const { SHOW_CHILD, TreeNode } = TreeSelect;
const { TextArea } = Input;

const DynamicRenderingForm = (props, ref) => {
    let timeout = null;
    // 表单元素ref集
    let formItemRef = useRef({});
    // 不需要创建ref的元素
    const noCreateRefFieldArr = ['Divider', 'CardTitle', 'AntdIconSelect', 'Occupy', 'Tag'];
    const propsRowData = props?.rowData || {};
    const propsFormData = props?.formData || [];
    const propsSelectData = props?.selectData || {};
    const userData = React.$getUserData();
    const [form] = Form.useForm();
    const [otherParams, setOtherParams] = useState({});
    const [formData, setFormData] = useState([]);
    const [filterFormData, setFilterFormData] = useState([]);
    const [rowData, setRowData] = useState({});
    const [selectData, setSelectData] = useState({});
    const [uploadLoading, setUploadLoading] = useState(false);
    const [spinLoading, setSpinLoading] = useState(false);

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        getFieldValue,
        getFieldsValue,
        setFieldValue,
        setFieldsValue,
        handleSave, // 保存 - 触发必填校验
        resetFields, // 重置表单
        modifyFormItemAttr, // 修改元素属性
        getFieldFocus, // 获取焦点
    }));

    useEffect(() => {
        if (JSON.stringify(propsRowData) !== JSON.stringify(rowData) || JSON.stringify(formData) !== JSON.stringify(propsFormData)) { // 弹窗赋值会报错，所以表单在打开弹窗的时候单独调
            const dataModifyFlag = JSON.stringify(rowData) === '{}' || JSON.stringify(rowData) !== JSON.stringify(propsRowData);
            setRowData(propsRowData);
            setFormData(propsFormData);
            handleDefaultAssignment(dataModifyFlag); // 存在关联取值的情况需要获取相对应的下拉数据
            handleDataTransformation(propsRowData, propsFormData);
        };
    }, [propsRowData, propsFormData]);

    useEffect(() => {
        if (JSON.stringify(selectData) !== JSON.stringify(propsSelectData)) {
            setSelectData(propsSelectData)
            handleDefaultAssignment();
        };
    }, [propsSelectData]);

    // 默认数据源赋值
    const handleDefaultAssignment = () => {
        try {
            // 过滤不显示(display:N)的数据
            let filterFormData = Util.customDeepCopy(propsFormData).filter(item => item?.display !== 'N');
            if (filterFormData && Array.isArray(filterFormData) && filterFormData.length > 0) {
                let linkSelectArr = [];
                for (let i = 0; i < filterFormData.length; i++) {
                    let additionalParameters = Util.getObjByUrlStr(filterFormData[i]?.params || '');
                    if (additionalParameters && Object.prototype.toString.call(additionalParameters) === '[object Object]' && JSON.stringify(additionalParameters) !== '{}') {
                        for (let otherKey in additionalParameters) {
                            filterFormData[i][otherKey] = additionalParameters[otherKey];
                        }
                    }
                    let currentIndex = i;
                    let currentTypeCode = filterFormData[i]?.typeCode || filterFormData[i]?.fieldTypeCode || '';
                    let dataIndex = filterFormData[i]?.dataIndex || filterFormData[i]?.code || '';
                    // 为表单元素创建ref
                    if (!(formItemRef && formItemRef.current && dataIndex in formItemRef.current && formItemRef.current[dataIndex])) {
                        if (currentTypeCode && noCreateRefFieldArr.indexOf(currentTypeCode) < 0) {
                            formItemRef.current[dataIndex] = React.createRef();
                        }
                    }
                    filterFormData[i].typeCode = currentTypeCode;
                    filterFormData[i].title = filterFormData[i]?.title || filterFormData[i]?.label || filterFormData[i]?.descripts || '';
                    if (filterFormData[i] && 'loading' in filterFormData[i]) {
                        filterFormData[i].loading = false;
                    }
                    if (filterFormData[i] && ('defaultValue' in filterFormData[i] || 'default' in filterFormData[i])) {
                        filterFormData[i].defaultValue = filterFormData[i]?.defaultValue || filterFormData[i]?.default || undefined;
                    }
                    let className = filterFormData[i]?.className || '';
                    if ('default' in filterFormData[i] && filterFormData[i].default !== '' && (currentTypeCode === 'Date' || currentTypeCode === 'DatePicker' || currentTypeCode === 'DateTime')) { // 默认日期
                        let dateNum = filterFormData[i].default && parseInt(filterFormData[i].default) && !isNaN(parseInt(filterFormData[i].default)) ? dayjs().subtract(parseInt(filterFormData[i].default), 'days') : dayjs();
                        let defaultDate = dayjs(dateNum).format(dayFormat);
                        if (currentTypeCode === 'DateTime') { // 如果是日期时间 - 则根据联类中维护的defaultType判断默认值类型，
                            let defaultType = filterFormData[i]?.defaultType || '';
                            defaultDate = defaultDate + ' ' + (defaultType === 'end' ? '23:59:59' : (defaultType === 'start' ? '00:00:00' : dayjs().format(timeFormat)));
                        }
                        filterFormData[i].defaultValue = defaultDate;
                    }
                    if ((parseInt(filterFormData[i].default) === 0 || filterFormData[i].default === 'currentDate') && currentTypeCode === 'Time') { // 默认时间
                        let defaultType = filterFormData[i]?.defaultType || '';
                        let defaultDateTime = defaultType === 'end' ? '23:59:59' : (defaultType === 'start' ? '00:00:00' : dayjs().format(timeFormat));
                        filterFormData[i].defaultValue = defaultDateTime;
                    }
                    if (filterFormData[i]?.disabledDate === 'disabledDate' && currentTypeCode === 'Date') { // 日期选择控制 - 根据关联类录入的字段判断
                        let disabledType = filterFormData[i]?.disabledType || '<';
                        filterFormData[i].disabledDate = (curDate) => {
                            return curDate && (disabledType === '>' ? curDate > dayjs().subtract(1, 'days').endOf('day').endOf('day') : ( // 今天之前的开始选择
                                disabledType === '>=' ? curDate >= dayjs().endOf('day') : ( // 今天或者今天之前的可以选择
                                    disabledType === '<' ? curDate < dayjs().endOf('day') : ( // 今天之后的开始选择
                                        disabledType === '<=' ? curDate <= dayjs().subtract(1, 'days').endOf('day') : '')))); // 今天或者今天之后的可以选择
                        }
                    }
                    let checkboxArr = filterFormData[i]?.detailItem?.item || filterFormData[i]?.detailItem || [];
                    if ('default' in filterFormData[i] && filterFormData[i].default !== '' && (currentTypeCode === 'Switch' || ((currentTypeCode === 'Checkbox' || currentTypeCode === 'CheckBox') && !(checkboxArr && checkboxArr.length > 0)))) { // 默认开关
                        filterFormData[i].defaultValue = filterFormData[i]?.default === 'Y' ? 'Y' : 'N';
                    }
                    if (filterFormData[i] && (currentTypeCode === 'Select' || currentTypeCode === 'AutoComplete' || currentTypeCode.indexOf('Radio') > -1)) { // 下拉框数据对应取值及数据默认
                        let selectDefault = filterFormData[i].default === 'currentHospID' ? userData?.hospID : (filterFormData[i].default === 'currentLocID' ? userData?.locID : (filterFormData[i].default === 'currentUserID' ? userData?.userID : (filterFormData[i] && 'default' in filterFormData[i] && filterFormData[i].default !== null && filterFormData[i].default !== undefined && filterFormData[i].default !== '' ? filterFormData[i].default : undefined)));
                        let rowDefault = undefined; // 后台下拉数据存在默认值的情况
                        let currentDetailItem = filterFormData[i]?.detailItem || [];
                        if (!(currentDetailItem && Array.isArray(currentDetailItem) && currentDetailItem.length > 0)) {
                            if (filterFormData[i].className && propsSelectData) {
                                for (let keys in propsSelectData) {
                                    if (filterFormData[i].className === keys) {
                                        currentDetailItem = propsSelectData[keys];
                                        filterFormData[i].detailItem = propsSelectData[keys];
                                        break;
                                    }
                                }
                            }
                            let currentDefaultItem = [];
                            if (currentDetailItem && currentDetailItem.length > 0 && selectDefault && selectDefault.indexOf('index-') > -1) { // 默认下标
                                let arrIndex = selectDefault.split('index-')[1];
                                currentDefaultItem = [currentDetailItem[arrIndex]];
                            } else { // 根据后台返回的默认标志默认
                                currentDefaultItem = currentDetailItem && Array.isArray(currentDetailItem) && currentDetailItem.filter(item => item.default === 'Y');
                            }
                            rowDefault = currentDefaultItem && currentDefaultItem.length > 0 ? (currentDefaultItem[0] && 'id' in currentDefaultItem[0] ? currentDefaultItem[0].id : undefined) : undefined;
                        }
                        let linkValueCodeArr = filterFormData[i] && 'linkValueCode' in filterFormData[i] ? (Array.isArray(filterFormData[i].linkValueCode) ? filterFormData[i].linkValueCode : [filterFormData[i].linkValueCode]) : [];
                        if (filterFormData[i].linkCode && linkValueCodeArr && linkValueCodeArr.length > 0 && dataIndex && propsRowData[dataIndex]) {
                            // handleSelectLinkChange(propsRowData[dataIndex], filterFormData[i], 'return', propsRowData); // 直接调用会有问题 - 导致formData数据更新成旧数据
                            linkSelectArr.push({ value: propsRowData[dataIndex], colItem: filterFormData[i] });
                        }
                        filterFormData[i].defaultValue = rowDefault !== null && rowDefault !== undefined ? rowDefault : (selectDefault !== null && selectDefault !== undefined ? selectDefault : (filterFormData[i]?.defaultValue || undefined));
                    }
                    if (currentTypeCode === 'SelectBox' || currentTypeCode === 'CheckGroup' || currentTypeCode === 'CheckBoxGroup' || currentTypeCode.indexOf('TreeSelect') > -1) { // 多选框
                        let checkDefault = filterFormData[i]?.default || '';
                        let checkDefaultArr = [];
                        if (filterFormData[i].className && propsSelectData) {
                            let checkDetailItem = [];
                            for (let keys in propsSelectData) {
                                if (filterFormData[i].className === keys) {
                                    checkDetailItem = propsSelectData[keys];
                                    filterFormData[i].detailItem = propsSelectData[keys];
                                    break;
                                }
                            }
                            // 根据接口返回默认标志默认数据
                            if (checkDetailItem && checkDetailItem.length > 0) {
                                for (let checkI = 0; checkI < checkDetailItem.length; checkI++) {
                                    if (checkDetailItem[checkI].default === 'Y') {
                                        checkDefaultArr.push(checkDetailItem[checkI]?.id || '')
                                    }
                                }
                            }
                            if (!(checkDefaultArr && checkDefaultArr.length > 0) && checkDefault) { // 通过表单那维护默认数据处理
                                if (checkDefault && checkDefault.indexOf(',') > -1) {
                                    checkDefaultArr = checkDefault.split(',');
                                } else {
                                    checkDefaultArr.push(checkDefault);
                                }
                            }
                        }
                        filterFormData[i].defaultValue = checkDefaultArr;
                    }
                    if (filterFormData[i] && currentTypeCode === 'SearchSelect' && className) { // 回车搜索列表展示
                        let baseRecord = filterFormData[i];
                        filterFormData[i].valueFieldName = baseRecord?.labelFieldName || 'descripts'; // 显示在界面上的值 -> 对应下拉数据返回的描述
                        filterFormData[i].valueID = baseRecord?.valueID || ''; // 需要存到后台的字段对应的id值 - 关联方法
                        filterFormData[i].onSearch = (e) => handleChargeSearch(e, currentIndex, baseRecord);
                    }
                    if (className && (currentTypeCode === 'Input' || currentTypeCode === 'inputNumber' || currentTypeCode === 'InputNumber' || currentTypeCode === 'CustomInputNumber')) {
                        if (className.indexOf(':') > -1) {
                            // 将关联类中的属性分割处理添加到数据中
                            if (filterFormData[i] && 'addonAfter' in filterFormData[i] && filterFormData[i]?.addonAfter === 'ColorPickup') {
                                filterFormData[i].addonAfter = (
                                    <div>
                                        <span className="span">{filterFormData[i]?.pickupTitle || '选择颜色'}</span>
                                    </div>
                                )
                            }
                        }
                    }
                    if ('default' in filterFormData[i] && filterFormData[i].default !== '' && currentTypeCode === 'RangePicker') { // 日期范围
                        const defaultDay = filterFormData[i]?.default || '';
                        let startDefaultDay = '';
                        let endDefaultDay = '';
                        // 拆分范围（如 "7^0" 表示最近7天到今天）
                        if (typeof defaultDay === 'string' && defaultDay.includes('^')) {
                            const [start, end] = defaultDay.split('^', 2);
                            startDefaultDay = start;
                            endDefaultDay = end;
                        } else if (defaultDay !== '') {
                            // 单值逻辑：正数用于开始（往前推），负数用于结束（往后推）
                            const num = Number(defaultDay);
                            if (!isNaN(num)) {
                                if (num >= 0) {
                                    startDefaultDay = String(num); // 如 7 → 开始日期 = 7天前
                                    endDefaultDay = '0';           // 结束日期 = 今天
                                } else {
                                    startDefaultDay = '0';         // 开始日期 = 今天
                                    endDefaultDay = String(num);   // 如 -3 → 结束日期 = 3天后
                                }
                            } else {
                                // 非数字字符串（如 'firstDay'），统一作为开始日期？
                                startDefaultDay = defaultDay;
                                endDefaultDay = defaultDay; // 或根据业务决定
                            }
                        }
                        // 解析开始和结束日期
                        let startValue = parseDefaultDate(startDefaultDay, true, dayFormat);
                        let endValue = parseDefaultDate(endDefaultDay, false, dayFormat);
                        // 处理 showTime 和时间部分
                        if (filterFormData[i]?.showTime === 'Y' || filterFormData[i]?.showTime === 'true' || filterFormData[i]?.showTime === true) {
                            const currentTime = dayjs().format('HH:mm:ss');
                            if (startValue) {
                                startValue += (filterFormData[i]?.startDefaultType === 'current' ? (' ' + currentTime) : ' 00:00:00');
                            }
                            if (endValue) {
                                endValue += (filterFormData[i]?.endDefaultType === 'current' ? (' ' + currentTime) : ' 23:59:59');
                            }
                        }
                        // 赋值
                        filterFormData[i].defaultValue = [startValue, endValue];
                    }
                    if (filterFormData[i].default === 'currentHospID') { // 默认当前登录医院
                        filterFormData[i].defaultValue = userData?.hospID || undefined;
                    }
                    if (filterFormData[i].default === 'currentLocID') { // 默认当前科室
                        filterFormData[i].defaultValue = userData?.locID || undefined;
                    }
                    if (filterFormData[i].default === 'currentUserID') { // 默认当前登录人
                        filterFormData[i].defaultValue = userData?.userID || undefined;
                    }
                    if (filterFormData[i].default === 'currentUserDesc') { // 默认当前登录人
                        filterFormData[i].defaultValue = userData?.userName || undefined;
                    }
                    if (filterFormData[i].default === 'empty') { // 空字符串
                        filterFormData[i].defaultValue = '';
                    }
                }
                setFilterFormData(filterFormData);
                if (Array.isArray(linkSelectArr) && linkSelectArr.length > 0) { // 获取关联下拉框数据
                    linkSelectArr.forEach(item => {
                        handleSelectLinkChange(item.value, item.colItem, 'return', propsRowData, filterFormData);
                    });
                }
            }
        } catch (error) {
            console.log(error);
        }
    };

    const parseDefaultDate = (value, isStartDate = true, dayFormat = 'YYYY-MM-DD') => {
        if (!value || value === 'none' || value === 'N') {
            return undefined;
        }
        // 特殊关键字
        if (value === 'firstDay') {
            return dayjs().startOf('month').format(dayFormat);
        }
        if (value === 'lastDay') {
            return dayjs().endOf('month').format(dayFormat);
        }
        // 尝试转为数字
        const num = Number(value);
        if (isNaN(num)) {
            // 如果不是数字，可能是格式化好的日期字符串，直接返回（需确保格式正确）
            return value;
        }
        let date;
        if (isStartDate) {
            // 开始日期：正数表示“往前推”，负数表示“往后推”
            if (num >= 0) {
                date = dayjs().subtract(num, 'days');
            } else {
                date = dayjs().add(-num, 'days'); // 注意：-(-5) = +5
            }
        } else {
            // 结束日期：正数表示“往前推”（如过去7天），负数表示“往后推”
            if (num <= 0) {
                date = dayjs().add(-num, 'days'); // 如 -3 → 往后3天
            } else {
                date = dayjs().subtract(num, 'days'); // 如 7 → 往前7天（常见于“最近7天”）
            }
        }
        return date.format(dayFormat);
    };

    // 数据转化 - 表单赋值前
    const handleDataTransformation = (pRowData, pFormData) => {
        let nOtherParams = {}; // 日期范围回显
        if (pFormData && Array.isArray(pFormData) && pFormData.length > 0) {
            for (let i = 0; i < pFormData.length; i++) {
                let additionalParameters = Util.getObjByUrlStr(pFormData[i]?.params || '');
                // internalFlag - 颜色选择器内部添加change事件选择标志
                if ((pFormData[i]?.typeCode === 'ColorPicker' && additionalParameters?.internalFlag === 'Y') || pFormData[i]?.typeCode === 'AntdIconSelect') {
                    let currentDataIndex = pFormData[i]?.dataIndex || pFormData[i]?.code || '';
                    nOtherParams[currentDataIndex] = JSON.stringify(pRowData) !== '{}' ? pRowData[currentDataIndex] : (pFormData[i]?.defaultValue || pFormData[i]?.default || undefined);
                }
            }
        };
        setOtherParams(oldData => {
            return {
                ...oldData,
                ...nOtherParams
            }
        });
        let values = getDataIndexValues(pRowData);
        setFieldsValue(formDataConversion({ ...values }));
    };

    // 远程搜索事件 
    const handleChargeSearch = (value, index, record) => {
        try {
            let nFilterFormData = filterFormData;
            nFilterFormData[index]['loading'] = true;
            setFilterFormData(nFilterFormData);
            fetchCharge(value, record, (selectData) => {
                let rFilterFormData = filterFormData;
                rFilterFormData[index]['loading'] = false;
                rFilterFormData[index]['detailItem'] = selectData;
                setFilterFormData(rFilterFormData);
            });
        } catch (error) {
            console.log(error);
        }
    };

    // 获取远程搜索下拉数据
    const fetchCharge = (value, record, callback) => {
        try {
            value = value.replace(/^\s+/, '').replace(/\s+$/, '');
            if (!(record && (record?.httpCode || record?.className))) {
                message.error('远程搜索请求接口维护异常！')
                return;
            };
            if (value === '') {
                let resData = [];
                callback(resData);
                return;
            }
            if (timeout) {
                clearTimeout(timeout);
                timeout = null;
            }
            async function fakeCharge() {
                let data = {
                    params: [{
                        [record?.httpDescField || record?.linkCode || 'desc']: value
                    }],
                    pagination: [{ // 数据太多的情况让后台分页，动态下拉最多展示500条
                        pageSize: 500,
                        currentPage: 1,
                    }]

                }
                let res = await React.$asyncPost(record?.httpCode || record?.className || '', data);
                let selectList = res && 'result' in res && res.result && Object.prototype.toString.call(res.result) === '[object Object]' ? (
                    res.result && 'rows' in res.result && res.result.rows ? res.result.rows : (
                        res.result && 'Data' in res.result && res.result.Data ? res.result.Data : (
                            res.result && 'data' in res.result && res.result.data ? res.result.data : []))) : (res?.result || res?.data || res?.Data || []);
                callback(selectList);
            }
            timeout = setTimeout(fakeCharge, 300);
        } catch (error) {
            console.log(error);
        }
    };

    // 下拉框关联取值 | 关联字段控制
    const handleSelectLinkChange = async (e, record, valType, rowData, pFilterFormData) => {
        try {
            let isUpDateState = false;
            let clearValues = {};
            let nFilterFormData = [...(pFilterFormData && Array.isArray(pFilterFormData) && pFilterFormData.length > 0 ? pFilterFormData : filterFormData)];
            let linkValueCodeArr = record && 'linkValueCode' in record ? (Array.isArray(record.linkValueCode) ? record.linkValueCode : [record.linkValueCode]) : [];
            if (linkValueCodeArr && linkValueCodeArr.length > 0) {
                let recordDetailItem = record?.detailItem || [];
                let linkCode = record?.linkCode || ''; // 关联取值接口代码
                let selectValues = Util.returnDataCccordingToAttributes(recordDetailItem, e, 'id');
                let typeCodeSelectFlag = getTypeCodeSelectFlag(linkValueCodeArr);
                if (selectValues && 'inputType' in selectValues && selectValues.inputType) { // 关联切换输入框类型
                    isUpDateState = true;
                    for (let i = 0; i < nFilterFormData.length; i++) {
                        let currentIndex = i;
                        let currentFormItem = nFilterFormData[i];
                        if (linkValueCodeArr && Array.isArray(linkValueCodeArr) && linkValueCodeArr.indexOf(currentFormItem.dataIndex) > -1) {
                            currentFormItem.typeCode = selectValues.inputType;
                            clearValues[currentFormItem.dataIndex] = undefined;
                            if (selectValues.inputType === 'SearchSelect') { // 远程搜索
                                currentFormItem.trigger = selectValues?.trigger || record?.trigger || 'Enter'; // 回车触发
                                currentFormItem.labelFieldName = selectValues?.labelFieldName || record?.labelFieldName || 'descripts';
                                currentFormItem.valueFieldName = selectValues?.valueFieldName || record?.valueFieldName || 'descripts';
                                currentFormItem.valueID = selectValues?.valueID || record?.valueID || 'id'; // 需要存到后台的字段对应的id值 - 关联方法
                                currentFormItem.httpCode = selectValues?.linkCode || linkCode || '';
                                currentFormItem.httpDescField = selectValues?.httpDescField || record?.httpDescField || 'desc';
                                currentFormItem.onSearch = (e) => handleChargeSearch(e, currentIndex, currentFormItem);
                            }
                        }
                    }
                } else if (typeCodeSelectFlag) { // 关联下一个为下拉框则获取数据
                    isUpDateState = true;
                    setSpinLoading(true);
                    let values = getFieldsValue('N');
                    let data = {
                        params: [{
                            ...(record?.linkStaticParams || {}), // 表单数据静态参数
                            ...(valType === 'return' ? rowData : values),
                            [record?.searchDataIndex || 'id']: e, // 可对应维护成关联方法
                            [record?.dataIndex || record?.code]: e,
                        }]
                    }
                    let res = await React.$asyncPost(linkCode, data);
                    // 取单个数据的情况
                    let detailItem = React.$processingTableRequestData(res);
                    let selectData = res && 'result' in res ? res.result : res; // 存在多个关联多个的情况
                    for (let i = 0; i < linkValueCodeArr.length; i++) {
                        let linkTypeRecord = Util.returnDataCccordingToAttributes(nFilterFormData, linkValueCodeArr[i], 'code');
                        if (linkTypeRecord?.typeCode === 'Select' || linkTypeRecord?.typeCode === 'SelectBox' || linkTypeRecord?.typeCode === 'MultipleSelect') {
                            for (let j = 0; j < nFilterFormData.length; j++) {
                                if (nFilterFormData[j].dataIndex === linkValueCodeArr[i]) {
                                    let currentDetailItem = linkValueCodeArr.length > 1 ? filterSelectData(selectData, linkValueCodeArr[i]) : detailItem;
                                    let currentDefaultVal = Util.returnDataCccordingToAttributes(currentDetailItem, 'Y', 'default')?.id;
                                    nFilterFormData[j].detailItem = currentDetailItem;
                                    clearValues[linkValueCodeArr[i]] = currentDefaultVal || undefined;
                                }
                            }
                            if (linkTypeRecord && 'linkValueCode' in linkTypeRecord) { // 栗：选择省同时清除区
                                if (linkTypeRecord.linkValueCode && Array.isArray(linkTypeRecord.linkValueCode)) { // 数组情况
                                    for (let k = 0; k < linkTypeRecord.linkValueCode.length; k++) {
                                        clearValues[linkTypeRecord.linkValueCode[k]] = undefined;
                                    }
                                } else {
                                    clearValues[linkTypeRecord.linkValueCode] = undefined;
                                }
                            }
                        } else if (linkTypeRecord?.typeCode === 'Input' || linkTypeRecord?.typeCode === 'inputNumber' || linkTypeRecord?.typeCode === 'InputNumber' || linkTypeRecord?.typeCode === 'CustomInputNumber') {
                            let inputValue = typeof (selectData) === 'string' ? selectData : (linkValueCodeArr[i] in selectData && selectData[linkValueCodeArr[i]] ? selectData[linkValueCodeArr[i]] : (selectData[record?.linkDataIndex || 'id'] || undefined));
                            clearValues[linkValueCodeArr[i]] = inputValue;
                        }
                    }
                }
            }
            // 关联不可操作状态控制
            let linkDisabledCodeArr = record && 'linkDisabledCode' in record ? (Array.isArray(record.linkDisabledCode) ? record.linkDisabledCode : [record.linkDisabledCode]) : [];
            if (linkDisabledCodeArr && linkDisabledCodeArr.length > 0) {
                isUpDateState = true;
                for (let i = 0; i < nFilterFormData.length; i++) {
                    let currentDataIndex = nFilterFormData[i]?.dataIndex || '';
                    if (linkDisabledCodeArr.indexOf(currentDataIndex) > -1) {
                        let setDisabled = e ? 'N' : 'Y';
                        nFilterFormData[i].disabled = setDisabled;
                        if (setDisabled === 'Y' && record?.linkDisabledClearFlag !== 'N') { // 置灰时清空关联数据
                            clearValues[currentDataIndex] = undefined;
                        }
                    }
                }
            }
            if (isUpDateState) {
                setSpinLoading(false);
                setFilterFormData(nFilterFormData);
                if (clearValues && Object.keys(clearValues).length !== 0 && valType !== 'return') { // 清除关联选择数据；栗：选择省清除市
                    setFieldsValue(clearValues);
                }
            }
        } catch (error) {
            console.log(error);
            setSpinLoading(false);
        }
    };

    const filterSelectData = (selectData, dataIndex) => {
        let detailItem = [];
        if (Object.prototype.toString.call(selectData) === '[object Object]') {
            for (let key in selectData) {
                if (dataIndex.indexOf(key) > -1) {
                    detailItem = selectData[key];
                    break;
                }
            }
        }
        return detailItem;
    };

    // 判断linkTypeCode中是否包含Select下拉元素
    const getTypeCodeSelectFlag = (linkValueCodeArr) => {
        let typeCodeSelectFlag = false;
        for (let j = 0; j < linkValueCodeArr.length; j++) {
            let linkTypeCode = Util.returnDataCccordingToAttributes(filterFormData && Array.isArray(filterFormData) && filterFormData.length > 0 ? filterFormData : propsFormData, linkValueCodeArr[j], 'code')?.typeCode || '';
            if (linkTypeCode === 'Select' || linkTypeCode === 'SelectBox' || linkTypeCode === 'MultipleSelect') {
                typeCodeSelectFlag = true;
                break;
            }
        }
        return typeCodeSelectFlag;
    };

    // 获取表单中的某个字段的值
    const getFieldValue = (dataIndex) => {
        let value = '';
        if (dataIndex) {
            value = form.getFieldValue(dataIndex);
        }
        return value;
    };

    // 获取表单值
    const getFieldsValue = () => {
        let values = formDataFormatConversion(form.getFieldsValue());
        return { ...values, ...otherParams };
    };

    // 表单赋值 - 单个字段赋值
    const setFieldValue = (dataIndex, value) => {
        if (dataIndex) {
            value = form.getFieldValue(dataIndex, value);
        }
    };

    // 表单赋值 - 根据对象赋值
    const setFieldsValue = (values) => {
        try {
            form && form.setFieldsValue({ ...values });
        } catch (error) {
            console.log(error);
        }
    };

    // 重置表单
    const resetFields = () => {
        form && form.resetFields();
    };

    useEffect(() => {
        if (props?.autoFocusFlag === 'Y' && filterFormData && Array.isArray(filterFormData) && filterFormData.length > 0) { // 自动获取焦点
            handleAutoFocus();
        }
    }, [filterFormData])

    // 获取输入域焦点【先找默认获取焦点标志，没有标志的话获取第一个】
    const handleAutoFocus = () => {
        // 查找自动焦点标志
        let autoFocusRecordData = Util.returnDataCccordingToAttributes(filterFormData, 'Y', 'autoFocusFlag');
        let focusDataIndex = autoFocusRecordData?.dataIndex || autoFocusRecordData?.code || '';
        if (!focusDataIndex) {
            for (let i = 0; i < filterFormData.length; i++) {
                let currentTypeCode = filterFormData[i]?.typeCode || filterFormData[i]?.fieldTypeCode || '';
                if (noCreateRefFieldArr.indexOf(currentTypeCode) < 0 && filterFormData[i]?.disabled !== 'Y') {
                    focusDataIndex = filterFormData[i]?.dataIndex || filterFormData[i]?.code || '';
                    break;
                }
            }
        }
        if (focusDataIndex) {
            setTimeout(() => {
                getFieldFocus(focusDataIndex)
            }, 300)
        }
    };

    // 指定输入域获取焦点
    const getFieldFocus = (dataIndex, focusType = 'end') => {
        let focusAttr = {};
        if (focusType === 'preventScroll') {
            focusAttr.preventScroll = true;
        } else {
            focusAttr.cursor = focusType;
        }
        // 指定元素
        if (dataIndex) {
            dataIndex && dataIndex in formItemRef.current && formItemRef.current[dataIndex] && formItemRef.current[dataIndex].current && formItemRef.current[dataIndex].current.focus(focusAttr);
        }
    };

    // 保存
    const handleSave = (isTip) => {
        return new Promise((resolve, reject) => {
            form && form.validateFields()
                // 验证成功
                .then(values => {
                    resolve({
                        ...otherParams,
                        ...formDataFormatConversion(values, 'undefined'),
                    });
                })
                .catch(() => {
                    isTip === 'Y' && message.error('请完善必填项！');
                    resolve({ error: true });
                })
        })
    };

    // 获取当前表单字段
    const getDataIndexValues = (rowData) => {
        let values = {};
        for (var i = 0; i < filterFormData.length; i++) {
            if (rowData && JSON.stringify(rowData) !== '{}') {
                values[filterFormData[i].dataIndex] = undefined;
                for (var keys in rowData) {
                    if (filterFormData[i].dataIndex === keys) {
                        values[keys] = rowData[keys] !== '' ? rowData[keys] : undefined;
                    }
                }
            } else { // 如果不是编辑则取默认值
                values[filterFormData[i].dataIndex] = filterFormData[i]?.defaultValue || undefined;
            }
        };
        return values;
    };

    // 表单数据格式转换 - 保存时
    const formDataFormatConversion = (fieldsValues, nullFlag) => {
        let nullVal = nullFlag === 'undefined' ? undefined : '';
        if (filterFormData && filterFormData.length > 0) {
            for (let i = 0; i < filterFormData.length; i++) {
                let checkboxArr = filterFormData[i]?.detailItem?.item || filterFormData[i]?.detailItem || [];
                let currentTypeCode = filterFormData[i]?.typeCode || '';
                for (let keys in fieldsValues) {
                    if (filterFormData[i].dataIndex === keys) {
                        fieldsValues[keys] = fieldsValues[keys] !== undefined && fieldsValues[keys] !== null ? fieldsValues[keys] : nullVal;
                        if (currentTypeCode === 'SearchSelect') {
                            // 修改了取修改后的值，没修改返回原值
                            let valID = filterFormData[i]?.valueID || '';
                            let currentFieldsObj = Util.returnDataCccordingToAttributes(filterFormData[i].detailItem, fieldsValues[keys], (filterFormData[i]?.labelFieldName || 'descripts'));
                            fieldsValues[valID] = (filterFormData[i] && filterFormData[i].oldValueFieldName ? currentFieldsObj[filterFormData[i].oldValueFieldName] : currentFieldsObj[valID]) || (currentFieldsObj?.id || rowData[valID]);
                        } else if (currentTypeCode === 'Switch' || ((currentTypeCode === 'Checkbox' || currentTypeCode === 'CheckBox') && !(checkboxArr && checkboxArr.length > 0))) { // 开关
                            fieldsValues[keys] = fieldsValues[keys] ? 'Y' : 'N';
                        } else if (currentTypeCode === 'RangePicker') { // 日期范围
                            let startKey = keys && keys.indexOf('^') > -1 ? keys.split('^')[0] : 'startDate';
                            let endKey = keys && keys.indexOf('^') > -1 ? keys.split('^')[1] : 'endDate';
                            let startValue, endValue;
                            if (filterFormData[i]?.showTime === 'Y' || filterFormData[i]?.showTime === 'true' || filterFormData[i]?.showTime === true) {
                                startValue = fieldsValues[keys] && Array.isArray(fieldsValues[keys]) && fieldsValues[keys][0] ? dayjs(fieldsValues[keys][0]).format(dateFormat) : nullVal;
                                endValue = fieldsValues[keys] && Array.isArray(fieldsValues[keys]) && fieldsValues[keys][1] ? dayjs(fieldsValues[keys][1]).format(dateFormat) : nullVal;
                            } else {
                                startValue = fieldsValues[keys] && Array.isArray(fieldsValues[keys]) && fieldsValues[keys][0] ? dayjs(fieldsValues[keys][0]).format(dayFormat) : nullVal;
                                endValue = fieldsValues[keys] && Array.isArray(fieldsValues[keys]) && fieldsValues[keys][1] ? dayjs(fieldsValues[keys][1]).format(dayFormat) : nullVal;
                            }
                            fieldsValues[startKey] = startValue;
                            fieldsValues[endKey] = endValue;
                            fieldsValues[keys] = startValue || endValue ? [startValue || '', endValue || ''] : nullVal;
                        } else if (currentTypeCode === 'DatePicker' || currentTypeCode === 'Date' || currentTypeCode === 'DateTime') {
                            if (!!(filterFormData[i]?.showTime) || currentTypeCode === 'DateTime') {
                                fieldsValues[keys] = fieldsValues[keys] ? dayjs(fieldsValues[keys]).format(dateFormat) : nullVal; // 日期时间
                            } else {
                                fieldsValues[keys] = fieldsValues[keys] ? dayjs(fieldsValues[keys]).format(dayFormat) : nullVal; // 日期
                            }
                        } else if (currentTypeCode === 'Time') { // 时间
                            fieldsValues[keys] = fieldsValues[keys] ? dayjs(fieldsValues[keys]).format(timeFormat) : nullVal;
                        } else if ((currentTypeCode === 'Select' || currentTypeCode.indexOf('Radio') > -1) && nullFlag !== 'N' && filterFormData[i].mode !== 'multiple') { // 获取下拉框对应的描述
                            let descCode = keys && keys.indexOf('ID') > -1 ? keys.replace('ID', 'Desc') : (keys + 'Desc');
                            fieldsValues[descCode] = Util.returnDataCccordingToAttributes(filterFormData[i].detailItem, fieldsValues[keys])?.descripts || nullVal;
                        } else if (currentTypeCode === 'ColorPicker') { // 颜色选择
                            fieldsValues[keys] = typeof fieldsValues[keys] === 'string' ? fieldsValues[keys] : fieldsValues[keys]?.toHexString();
                        }
                    }
                }
            }
        };
        return fieldsValues;
    };

    // 表单数据转换 - 使用
    const formDataConversion = fieldsValues => {
        if (filterFormData && filterFormData.length > 0) {
            for (let i = 0; i < filterFormData.length; i++) {
                let checkboxArr = filterFormData[i]?.detailItem?.item || filterFormData[i]?.detailItem || [];
                let currentTypeCode = filterFormData[i]?.typeCode || '';
                for (let keys in fieldsValues) {
                    if (filterFormData[i].dataIndex === keys) {
                        if (currentTypeCode === 'Switch' || ((currentTypeCode === 'Checkbox' || currentTypeCode === 'CheckBox') && !(checkboxArr && checkboxArr.length > 0))) { // 开关
                            fieldsValues[keys] = fieldsValues[keys] === 'Y' ? true : false;
                        } else if (currentTypeCode === 'RangePicker') { // 日期范围
                            let startKey = keys && keys.indexOf('^') > -1 ? keys.split('^')[0] : 'startDate';
                            let endKey = keys && keys.indexOf('^') > -1 ? keys.split('^')[1] : 'endDate';
                            let startValue = Array.isArray(fieldsValues[keys]) && fieldsValues[keys].length > 0 ? fieldsValues[keys][0] : fieldsValues[startKey];
                            let endValue = Array.isArray(fieldsValues[keys]) && fieldsValues[keys].length > 0 ? fieldsValues[keys][1] : fieldsValues[endKey];
                            if (filterFormData[i]?.showTime === 'Y' || filterFormData[i]?.showTime === 'true' || filterFormData[i]?.showTime === true) {
                                startValue = startValue ? dayjs(startValue, dateFormat) : null;
                                endValue = endValue ? dayjs(endValue, dateFormat) : null;
                            } else {
                                startValue = startValue ? dayjs(startValue, dayFormat) : null;
                                endValue = endValue ? dayjs(endValue, dayFormat) : null;
                            }
                            fieldsValues[startKey] = startValue;
                            fieldsValues[endKey] = endValue;
                            fieldsValues[keys] = [startValue, endValue];
                        } else if (currentTypeCode === 'DatePicker' || currentTypeCode === 'Date' || currentTypeCode === 'DateTime') {
                            if (!!(filterFormData[i]?.showTime) || currentTypeCode === 'DateTime') {
                                fieldsValues[keys] = fieldsValues[keys] ? dayjs(fieldsValues[keys], dateFormat) : fieldsValues[keys]; // 日期时间
                            } else {
                                fieldsValues[keys] = fieldsValues[keys] ? dayjs(fieldsValues[keys], dayFormat) : fieldsValues[keys]; // 日期
                            }
                        } else if (currentTypeCode === 'Time') { // 时间
                            fieldsValues[keys] = fieldsValues[keys] ? dayjs(fieldsValues[keys], timeFormat) : fieldsValues[keys];
                        } else if (currentTypeCode === 'Select') { // 下拉框
                            fieldsValues[keys] = fieldsValues[keys] && typeof (fieldsValues[keys]) === 'number' ? String(fieldsValues[keys]) : fieldsValues[keys];
                        } else if (currentTypeCode === 'UploadFile' || currentTypeCode === 'UploadImg') { // 上传
                            fieldsValues[keys] = fieldsValues[keys] && Array.isArray(fieldsValues[keys]) ? fieldsValues[keys] : [];
                        }
                    }
                }
            }
        };

        return fieldsValues;
    };

    // change事件回调赋值
    const handleChangeCallBack = (e, dataIndex, callBack, callBackDataIndex) => {
        let fieldsValue = getFieldsValue();
        if (callBackDataIndex === 'Fn') { // change回调
            callBack && callBack(e, dataIndex, {
                ...fieldsValue,
                [dataIndex]: e
            });
        }
    };

    // 动态创建图标组件
    const iconBC = useCallback((name, color = 'currentColor') => {
        return React.createElement(Icon[name], {
            style: { color }, // 或 { fill: color }，见下方说明
        });
    }, []);

    // 图标选择
    const handleModifyOtherParams = (val, dataIndex, item) => {
        setOtherParams(oldData => {
            return {
                ...oldData,
                [dataIndex]: val
            }
        })
    };

    const renderFormItem = (formData) => {
        let { formItemCol } = props;
        return formData && formData.map((childItem, childIndex) => {
            let currentInput = childItem?.typeCode || childItem?.fieldTypeCode || '';
            let dataIndex = childItem?.dataIndex || childItem?.code || '';
            let className = childItem?.className || '';
            let itemCol = 'formItemCol' in childItem ? childItem.formItemCol : (formItemCol || { labelCol: 8, wrapperCol: 16 });
            // label处理
            let labelDom = (
                'doubt' in childItem && childItem.doubt ? (
                    <span>
                        <span className="ellipsis" title={childItem.title}>{childItem.title}</span>
                        <Tooltip title={childItem.doubt}>
                            <QuestionCircleOutlined style={{ marginLeft: '4px', color: '#999' }} />
                        </Tooltip>
                    </span>
                ) : (
                    <span className="ellipsis" title={childItem.title}>{childItem.title}</span>
                )
            );
            return (
                <Col
                    key={childIndex}
                    style={childItem.style || ''}
                    xs={parseInt(childItem && childItem.col ? childItem.col : (formItemCol && formItemCol.col ? formItemCol.col : 12)) + 12}
                    sm={parseInt(childItem && childItem.col ? childItem.col : (formItemCol && formItemCol.col ? formItemCol.col : 12)) + 8}
                    md={parseInt(childItem && childItem.col ? childItem.col : (formItemCol && formItemCol.col ? formItemCol.col : 12)) + 6}
                    lg={parseInt(childItem && childItem.col ? childItem.col : (formItemCol && formItemCol.col ? formItemCol.col : 12)) + 4}
                    xl={parseInt(childItem && childItem.col ? childItem.col : (formItemCol && formItemCol.col ? formItemCol.col : 12)) + 2}
                    xxl={parseInt(childItem && childItem.col ? childItem.col : (formItemCol && formItemCol.col ? formItemCol.col : 12))}
                >
                    {!currentInput || currentInput === 'Occupy' ? (
                        <div style={{ width: '100%', height: '50px' }}>
                            {/* 占位 */}
                        </div>
                    ) : (currentInput === 'Switch' ? (
                        <Form.Item
                            valuePropName="checked"
                            name={dataIndex}
                            label={childItem?.title === 'none' ? '' : labelDom}
                            labelCol={{ span: parseInt('labelCol' in childItem && childItem.labelCol !== '' ? childItem.labelCol : ('labelCol' in itemCol && itemCol.labelCol !== '' ? itemCol.labelCol : 8)) }}
                            wrapperCol={{ span: parseInt('wrapperCol' in childItem && childItem.wrapperCol !== '' ? childItem.wrapperCol : ('wrapperCol' in itemCol && itemCol.wrapperCol !== '' ? itemCol.wrapperCol : 16)) }}
                            initialValue={rowData && rowData[dataIndex] ? (rowData[dataIndex] === 'Y' ? true : false) : (childItem.defaultValue === 'Y' ? true : false)}
                            rules={[{ required: childItem.required && childItem.required === 'Y' ? true : false }]}
                        >
                            {getInput(childItem)}
                        </Form.Item>
                    ) : (currentInput === 'Tag' ? (
                        <div style={{ paddingLeft: '48px', marginBottom: '12px' }}>
                            <Tag style={{ width: '100%', fontSize: '12pt', marginRight: 0 }} color='gold'>{childItem.title + '：' + (childItem.value ? childItem.value : '')}</Tag>
                        </div>
                    ) : ((currentInput === 'Upload' || currentInput === 'UploadFile' || currentInput === 'UploadImg') ? ( // 上传
                        <Form.Item
                            valuePropName="fileList"
                            extra={childItem.extra ? childItem.extra : ''}
                            label={childItem?.title === 'none' ? '' : labelDom} labelCol={{ span: parseInt('labelCol' in childItem && childItem.labelCol !== '' ? childItem.labelCol : ('labelCol' in itemCol && itemCol.labelCol !== '' ? itemCol.labelCol : 8)) }}
                            wrapperCol={{ span: parseInt('wrapperCol' in childItem && childItem.wrapperCol !== '' ? childItem.wrapperCol : ('wrapperCol' in itemCol && itemCol.wrapperCol !== '' ? itemCol.wrapperCol : 16)) }}
                            rules={[{ required: childItem.required && childItem.required === 'Y' ? true : false }]}
                        >
                            {getInput(childItem)}
                        </Form.Item>
                    ) : (currentInput === 'Button' ? (
                        childItem?.btnType === 'Upload' || childItem?.btnType === 'upload' ? (
                            <Upload {...(childItem?.uploadParams || {})}>
                                <Button
                                    icon={!!(childItem?.icon) && typeof (childItem?.icon || '') === 'string' ? iconBC(childItem?.icon || '', childItem?.iconColor || '') : (childItem?.icon || null)}
                                    ghost={childItem.ghost || false}
                                    loading={childItem.loading || false}
                                    className={className}
                                    type={childItem.type || 'default'}
                                    style={{
                                        ...(childItem?.btnStyle || {})
                                    }}
                                >
                                    {childItem.title}
                                </Button>
                            </Upload>
                        ) : (
                            <Button
                                icon={!!(childItem?.icon) && typeof (childItem?.icon || '') === 'string' ? iconBC(childItem?.icon || '', childItem?.iconColor || '') : (childItem?.icon || null)}
                                ghost={childItem.ghost || false}
                                loading={childItem.loading || false}
                                className={className}
                                type={childItem.type || 'default'}
                                style={{
                                    ...(childItem?.btnStyle || {})
                                }}
                                onClick={childItem.onClick || null}
                            >
                                {childItem.title}
                            </Button>
                        )
                    ) : (childItem?.typeCode === 'Divider' ? (
                        <div style={{ padding: '0 4px 0 8px' }}>
                            <Divider
                                type={childItem?.type || 'horizontal'}
                                style={{
                                    margin: childItem?.title === 'none' || childItem?.title === 'N' ? '' : '8px 0',
                                    fontSize: '13px',
                                    color: '#999',
                                    fontWeight: 'normal',
                                }}
                                orientation={className || 'center'} // 显示位置
                                dashed={childItem?.linkMethod === 'true' || childItem?.linkMethod === 'Y' ? true : false} // 是否虚线
                            >
                                {childItem?.title === 'none' || childItem?.title === 'N' ? '' : (childItem?.title || '')}
                            </Divider>
                        </div>
                    ) : (childItem?.typeCode === 'CardTitle' ? (
                        <div style={{ fontWeight: 900, marginBottom: '12px' }} className="common-card-title-vertical-line">
                            <div style={{ width: '3px' }}></div>
                            {childItem.title}
                        </div>
                    ) : (childItem?.typeCode === 'AntdIconSelect' ? ( // 图标选择
                        <Row className="ant-form-item drf-antd-icon-select">
                            <Col
                                className="ant-form-item-label"
                                span={parseInt('labelCol' in childItem && childItem.labelCol !== '' ? childItem.labelCol : ('labelCol' in itemCol && itemCol.labelCol !== '' ? itemCol.labelCol : 8))}
                            >
                                <label className={childItem.required === 'Y' ? 'ant-form-item-required' : ''}>
                                    <span>{childItem?.descripts || '图标选择'}</span>
                                </label>
                            </Col>
                            <Col span={parseInt('wrapperCol' in childItem && childItem.wrapperCol !== '' ? childItem.wrapperCol : ('wrapperCol' in itemCol && itemCol.wrapperCol !== '' ? itemCol.wrapperCol : 16))}>
                                <div className="flex-wrap drf-antd-icon-select-body">
                                    {menuIcons && menuIcons.map((item, index) => {
                                        return (
                                            <span
                                                key={index}
                                                style={{
                                                    backgroundColor: otherParams && dataIndex in otherParams && otherParams[dataIndex] === item ? (
                                                        otherParams && className in otherParams && otherParams[className] ? otherParams[className] : 'var(--main-bg)'
                                                    ) : ''
                                                }}
                                                className={[
                                                    'flex-center',
                                                    'drf-antd-icon-select-item',
                                                    otherParams && dataIndex in otherParams && otherParams[dataIndex] === item ? 'drf-antd-icon-select-item-active' : ''
                                                ].join(' ')}
                                                onClick={() => handleModifyOtherParams(item, dataIndex, childItem)}
                                            >
                                                {iconBC(item)}
                                            </span>
                                        )
                                    })}
                                </div>
                            </Col>
                        </Row>
                    ) : (
                        <Form.Item
                            name={dataIndex}
                            label={childItem?.title === 'none' ? '' : labelDom}
                            labelCol={{ span: parseInt('labelCol' in childItem && childItem.labelCol !== '' ? childItem.labelCol : ('labelCol' in itemCol && itemCol.labelCol !== '' ? itemCol.labelCol : 8)) }}
                            wrapperCol={{ span: parseInt('wrapperCol' in childItem && childItem.wrapperCol !== '' ? childItem.wrapperCol : ('wrapperCol' in itemCol && itemCol.wrapperCol !== '' ? itemCol.wrapperCol : 16)) }}
                            initialValue={dataIndex && rowData && dataIndex in rowData && rowData[dataIndex] !== null && rowData[dataIndex] !== undefined ?
                                ((currentInput === 'DatePicker' || currentInput === 'Date' || currentInput === 'Time') ? (rowData[dataIndex] ? (
                                    currentInput === 'Time' ? dayjs(rowData[dataIndex], timeFormat) : dayjs(rowData[dataIndex])) : undefined
                                ) : (
                                    currentInput === 'Select' ? (
                                        typeof rowData[dataIndex] === 'number' ? String(rowData[dataIndex]) : rowData[dataIndex]
                                    ) : (currentInput === 'RangePicker' ? (
                                        Array.isArray(rowData[dataIndex]) && rowData[dataIndex].length === 2 ? (
                                            [!!(rowData[dataIndex][0]) ? dayjs(rowData[dataIndex][0], (!!(childItem?.showTime) ? dateFormat : dayFormat)) : undefined,
                                            !!(rowData[dataIndex][1]) ? dayjs(rowData[dataIndex][1], (!!(childItem?.showTime) ? dateFormat : dayFormat)) : undefined]
                                        ) : undefined
                                    ) : rowData[dataIndex])
                                )) :
                                (childItem && 'defaultValue' in childItem && childItem.defaultValue !== null && childItem.defaultValue !== undefined ? (
                                    (currentInput === 'DatePicker' || currentInput === 'Date' || currentInput === 'Time') ? (
                                        childItem.defaultValue ? dayjs(childItem.defaultValue) : undefined
                                    ) : (currentInput === 'RangePicker' && Array.isArray(childItem.defaultValue) && childItem.defaultValue.length === 2 ? (
                                        [!!(childItem.defaultValue[0]) ? dayjs(childItem.defaultValue[0], (!!(childItem?.showTime) ? dateFormat : dayFormat)) : undefined,
                                        !!(childItem.defaultValue[1]) ? dayjs(childItem.defaultValue[1], (!!(childItem?.showTime) ? dateFormat : dayFormat)) : undefined]
                                    ) : childItem.defaultValue)) : undefined)}
                            rules={[{ required: childItem.required && childItem.required === 'Y' ? true : false, message: '不能为空' }]}
                        >
                            {getInput(childItem)}
                        </Form.Item>
                    ))))))))
                    }
                </Col >
            )
        })
    };

    const getInput = (item) => {
        const { idField = 'id', isEnterJump } = props;
        const currentTypeCode = item?.typeCode || '';
        const currentDataIndex = item?.dataIndex || '';
        const linkValueCodeArr = item && 'linkValueCode' in item ? (Array.isArray(item.linkValueCode) ? item.linkValueCode : [item.linkValueCode]) : [];
        const linkDisabledCodeArr = item && 'linkDisabledCode' in item ? (Array.isArray(item.linkDisabledCode) ? item.linkDisabledCode : [item.linkDisabledCode]) : [];
        // compileDisabledFlag - 编辑内容时不可操作标志
        const currentDisabled = item?.disabled === 'Y' ? true : (item?.compileDisabledFlag === 'Y' && rowData && idField in rowData && rowData[idField] ? true : false);
        if (currentTypeCode === 'SearchSelect') { // 搜索下拉框
            return (
                <Select
                    allowClear
                    showSearch
                    placeholder={item?.placeholder || '请输入'}
                    style={{ ...(item?.inputStyle || {}), width: item && item.width ? (item.width + 'px') : '100%' }}
                    notFoundContent={null}
                    defaultActiveFirstOption={false}
                    filterOption={false}
                    disabled={currentDisabled}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                    onSearch={item.onSearch || null}
                    onSelect={item && item.changeCallBack ? (e) => handleChangeCallBack(e, item.dataIndex, item.changeCallBack, item.callBackResult) : null}
                >
                    {item.detailItem && Array.isArray(item.detailItem) && item.detailItem.map((childItem, childIndex) => {
                        let title = 'labelFieldName' in item && item.labelFieldName ? childItem[item.labelFieldName] : (childItem?.descripts || '');
                        let titleCode = 'descCodeIndex' in item && item.descCodeIndex ? childItem[item.descCodeIndex] : childItem.descriptsSPCode;
                        return (
                            <Option
                                disabled={currentDisabled}
                                value={'valueFieldName' in item && item.valueFieldName ? childItem[item.valueFieldName] : childItem.id}
                                key={childIndex}
                                title={title}
                                search={title + '^' + titleCode}
                            >
                                {title}
                            </Option>
                        )
                    })}
                </Select>
            )
        } else if (currentTypeCode === 'Select' || currentTypeCode === 'SelectMultiple' || currentTypeCode === 'SelectBox') { // 下拉框
            return (
                <Select
                    showSearch
                    allowClear
                    optionFilterProp="search"
                    mode={currentTypeCode === 'SelectMultiple' || currentTypeCode === 'SelectBox' ? 'multiple' : (item && item.mode ? item.mode : null)} // mode="multiple" 多选
                    placeholder={item?.placeholder || '请选择'}
                    style={{ ...(item?.inputStyle || {}), width: item && item.width ? (item.width + 'px') : '100%' }}
                    disabled={currentDisabled}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                    onSelect={item && item.changeCallBack ? (e) => handleChangeCallBack(e, item.dataIndex, item.changeCallBack, item.callBackResult) : (item.onSelect || null)}
                    onChange={((linkValueCodeArr && Array.isArray(linkValueCodeArr) && linkValueCodeArr.length > 0) || (linkDisabledCodeArr && Array.isArray(linkDisabledCodeArr) && linkDisabledCodeArr.length > 0)) ? (e) => handleSelectLinkChange(e, item) : null}
                >
                    {item.detailItem && Array.isArray(item.detailItem) ? React.$SelectOptions(
                        item.detailItem,
                        'valueFieldName' in item && item.valueFieldName ? item.valueFieldName : '',
                        'labelFieldName' in item && item.labelFieldName ? item.labelFieldName : ''
                    ) : ''}
                </Select>
            );
        } else if (currentTypeCode === 'Cascader') { // 级联选择
            return (
                <Cascader
                    placeholder={item?.placeholder || '请选择'}
                    fieldNames={{
                        label: item.labelFieldName ? item.labelFieldName : 'descripts',
                        value: item.valueFieldName ? item.valueFieldName : 'id',
                        children: item.childrenFieldName ? item.childrenFieldName : 'children'
                    }}
                    disabled={currentDisabled}
                    multiple={item.multiple ? item.multiple : false}
                    options={item?.detailItem || []}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                    onChange={item && item.changeCallBack ? (e) => handleChangeCallBack(e, item.dataIndex, item.changeCallBack, item.callBackResult) : null}
                />
            );
        } else if (currentTypeCode === 'CustomInputNumber') { // 数字框
            return (
                <Input
                    placeholder={item?.placeholder || '请输入'}
                    disabled={currentDisabled}
                    style={{ ...(item?.inputStyle || {}), width: item && item.width ? item.width : '100%' }}
                    type="number"
                    className="common-custom-input-number"
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                    onBlur={item.onBlur || null}
                    onPressEnter={item.onPressEnter || null}
                    onChange={item && item.changeCallBack ? (e) => handleChangeCallBack(e.target.value, i, item.changeCallBack, item.callBackResult, item.dataIndex) : (item.onChange || null)}
                />);
        } else if ((currentTypeCode === 'inputNumber') || (currentTypeCode === 'InputNumber')) { // 数字框
            return (
                <InputNumber
                    placeholder={item?.placeholder || '请输入'}
                    disabled={currentDisabled}
                    style={{ ...(item?.inputStyle || {}), width: item && item.width ? item.width : '100%' }}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                    onBlur={item.onBlur || null}
                    onPressEnter={item.onPressEnter || null}
                    onChange={item && item.changeCallBack ? (e) => handleChangeCallBack(e.target.value, i, item.changeCallBack, item.callBackResult, currentDataIndex) : (item.onChange || null)}
                />);
        } else if (currentTypeCode === 'Checkbox') { // 多选框
            return (
                <div>
                    <Checkbox.Group disabled={currentDisabled}>
                        {item.detailItem && item.detailItem.item && item.detailItem.item.map((childItem, childIndex) => {
                            return (
                                <Checkbox disabled={childItem && childItem.disabled ? true : false} value={childItem.itemID} key={childIndex}>{childItem.itemValue}</Checkbox>
                            )
                        })}
                    </Checkbox.Group>
                </div>
            );
        } else if (currentTypeCode === 'Switch') { // 开关
            return (
                <Switch
                    checkedChildren="是"
                    unCheckedChildren="否"
                    onChange={item && item.changeCallBack ? (e) => handleChangeCallBack(e, currentDataIndex, item.changeCallBack, item.callBackResult) : null}
                    disabled={currentDisabled}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                />
            );
        } else if (currentTypeCode === 'Radio') { // 单选框
            return (
                <Radio.Group disabled={currentDisabled}>
                    {item.detailItem && Array.isArray(item.detailItem) && item.detailItem.map((childItem, childIndex) => {
                        return (
                            <Radio
                                value={childItem?.id || childItem?.itemID || childItem?.key || ''}
                                key={childIndex}
                            >
                                {childItem?.descripts || childItem?.label || childItem?.itemValue || ''}
                            </Radio>
                        )
                    })}
                </Radio.Group>
            );
        } else if (currentTypeCode === 'RadioImageCard') { // 图片卡选择 - 单选框带图片及描述
            return (
                <Radio.Group disabled={currentDisabled} className="flex-wrap drf-radio-image-card">
                    {item.detailItem && Array.isArray(item.detailItem) && item.detailItem.map((childItem, childIndex) => {
                        return (
                            <div
                                key={childIndex}
                                style={{ marginBottom: item.detailItem.length > 2 && (childIndex < (item.detailItem.length - (item.detailItem.length % 2 === 1 ? 1 : 2))) ? '8px' : '0px' }}
                                className="flex-column-justify-content drf-radio-image-body"
                            >
                                <Radio
                                    key={childIndex}
                                    disabled={childItem?.disabled === 'Y' ? true : (currentDisabled)}
                                    value={childItem?.id || childItem?.itemID || childItem?.key || ''}
                                    title={childItem?.doubt || childItem?.introduceDesc || ''}
                                    className="drf-radio-image-item"
                                >
                                    <Image
                                        width="100%"
                                        className="drf-radio-image-item-bg"
                                        src={childItem?.images || childItem?.image || 'error'}
                                        preview={{
                                            src: childItem?.previewImages || childItem?.previewImage || childItem?.images || childItem?.image || 'error',
                                        }}
                                    />
                                    <div style={{ padding: '6px 12px' }}>
                                        <div className="flex-align-items">
                                            <span className="ant-radio-inner" style={{ marginRight: '6px' }}></span>
                                            {childItem?.descripts || childItem?.label || childItem?.itemValue || ''}
                                        </div>
                                        <div className="drf-radio-image-item-doubt">{childItem?.doubt || childItem?.introduceDesc || ''}</div>
                                    </div>
                                </Radio>
                            </div>
                        )
                    })}
                </Radio.Group>
            );
        } else if (currentTypeCode === 'RangePicker') { // 日期范围框
            return (
                <RangePicker
                    disabled={currentDisabled}
                    showTime={item?.showTime === 'Y' || item?.showTime === 'true' || item?.showTime === true ? true : false}
                    style={{ ...(item?.inputStyle || {}), width: item && item.width ? (item.width + 'px') : '100%' }}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                />
            );
        } else if (currentTypeCode === 'DateTime') { // 日期框
            return (
                <DatePicker
                    disabled={currentDisabled}
                    showTime={true}
                    style={{ ...(item?.inputStyle || {}), width: item && item.width ? (item.width + 'px') : '100%' }}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                />
            );
        } else if (currentTypeCode === 'DatePicker' || currentTypeCode === 'Date') { // 日期框
            return (
                <DatePicker
                    disabled={currentDisabled}
                    showTime={item && item.showTime ? item.showTime : false}
                    style={{ ...(item?.inputStyle || {}), width: item && item.width ? (item.width + 'px') : '100%' }}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                />
            );
        } else if (currentTypeCode === 'Time') { // 时间框
            return (
                <TimePicker
                    disabled={currentDisabled}
                    style={{ ...(item?.inputStyle || {}), width: item && item.width ? (item.width + 'px') : '100%' }}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                />
            )
        } else if (currentTypeCode === 'Upload') { // 上传
            const uploadImage = (
                <div>
                    {item.loading ? <LoadingOutlined /> : <PlusOutlined />}
                    <div style={{ marginTop: 8 }}>Upload</div>
                </div>
            );

            const uploadButton = <Button icon={<UploadOutlined />}>文件上传</Button>
            return (
                <Upload
                    className={item.uploadType === 'file' ? '' : 'avatar-uploader'}
                    showUploadList={false}
                    name={item?.fileName || item?.title || ''}
                    action={item?.action || ''}
                    listType={item?.listType || 'picture-card'}
                    fileList={item.fileList || []}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                    onChange={(e) => handleUploadFileChange(e, item, index)}
                    beforeUpload={item.beforeUpload ? item.beforeUpload : (e) => handleUploadImgBeforeUpload(e, item, index)}
                >
                    {item.uploadType === 'file' ? uploadButton : (item.imageUrl ? <img src={item.imageUrl} alt="avatar" style={{ width: '100%' }} /> : uploadImage)}
                </Upload>
            )
        } else if (currentTypeCode === 'TextArea') {
            return (
                <TextArea
                    autoSize={{ minRows: item?.minRows || 2, maxRows: item?.maxRows || 6 }}
                    placeholder={item?.placeholder || '请输入'}
                    style={{ ...(item?.inputStyle || {}), width: item && item.width ? (item.width + 'px') : '100%' }}
                    disabled={currentDisabled}
                    onBlur={item.onBlur || null}
                    onClick={item.onClick || null}
                    onPressEnter={item.onPressEnter || null}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                    onChange={item && item.changeCallBack ? (e) => handleChangeCallBack(e.target.value, i, item.changeCallBack, item.callBackResult, currentDataIndex, item) : (item.onChange || null)}
                />
            )
        } else if (item?.typeCode === 'TreeSelect' || item?.typeCode === 'TreeSelectCheck') { // 树选择 - 树多选
            const tProps = {
                showSearch: true,
                treeNodeFilterProp: 'search',
                showCheckedStrategy: SHOW_CHILD,
                treeDefaultExpandedKeys: [],
                searchPlaceholder: '输入关键字检索',
                placeholder: item.placeholder ? (item.placeholder !== 'none' ? item.placeholder : '') : '请选择',
                style: {
                    width: item && item.width ? (item.width + 'px') : '100%',
                },
                ref: item.onRef || (item.isEnterJump === 'Y' || isEnterJump === 'Y' ? (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null) : null),
                onChange: item && item.changeCallBack ? (e) => handleChangeCallBack(e, i, item.changeCallBack, item.callBackResult, currentDataIndex, item) : null,
            }
            if (item.typeCode === 'TreeSelectCheck') {
                tProps.treeCheckable = true;
            }
            return (
                <TreeSelect {...tProps}>
                    {renderTreeNodes(item?.detailItem || [], item?.typeCode || '')}
                </TreeSelect>
            );
        } else if (currentTypeCode === 'ColorPicker') { // 颜色选择器
            return (
                <ColorPicker
                    showText={item && 'showText' in item ? item.showText : true}
                    defaultFormat={item?.defaultFormat || 'hex'}
                    disabled={currentDisabled}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                    onClick={item.onClick || null}
                    onChange={item && item.changeCallBack ? (
                        (e) => handleChangeCallBack(e, i, item.changeCallBack, item.callBackResult, currentDataIndex, item)
                    ) : (
                        item?.internalFlag === 'Y' ? (e) => handleModifyOtherParams(typeof e === 'string' ? e : e?.toHexString(), currentDataIndex) : (item.onChange || null)
                    )}
                />
            )
        } else {
            return (
                <Input
                    placeholder={item?.placeholder || '请输入'}
                    style={{ ...(item?.inputStyle || {}), width: item && item.width ? (item.width + 'px') : '100%' }}
                    disabled={currentDisabled}
                    ref={item.onRef || (formItemRef && formItemRef.current && currentDataIndex in formItemRef.current ? formItemRef.current[currentDataIndex] : null)}
                    onBlur={item.onBlur || null}
                    onClick={item.onClick || null}
                    onKeyDown={item.onKeyDown || null}
                    onPressEnter={item.onPressEnter || null}
                    onDoubleClick={item.onDoubleClick || null}
                    onChange={item && item.changeCallBack ? (e) => handleChangeCallBack(e.target.value, i, item.changeCallBack, item.callBackResult, currentDataIndex, item) : (item.onChange || null)}
                />
            )
        }
    };

    const handleUploadImgBeforeUpload = (file, record, index) => {
        const isJpgOrPng = file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/jpg';
        if (!isJpgOrPng) {
            message.error('图片格式异常');
            return;
        }
        const isLt2M = file.size / 1024 / 1024 < 2;
        if (!isLt2M) {
            message.error('图片大小不能超过2MB!');
        }
        return false;
    };

    // 图片上传change事件
    const handleUploadFileChange = (info, record, index) => {
        const { fileType, uploadUrl } = props;
        setUploadLoading(true);
        let fileList = info?.fileList || [];
        let currentFile = info?.file || info;
        // 如果是删除的话直接
        if (currentFile?.status === 'removed') { // 删除
            record.fileList = fileList;
            record.dataIndex && setFieldsValue({
                [record.dataIndex]: fileList
            });
            setUploadLoading(false);
            return;
        };
        let data = new FormData();
        data.append('file', currentFile);
        const option = {
            method: 'post',
            mode: 'cors',
            headers: {},
            body: data
        };
        let uploadPath = '';
        if (!!(record?.uploadUrl)) {
            uploadPath = (record?.uploadUrl || '') + (!!(record?.fileType) ? ('?fileType=' + (record?.fileType || '')) : '') + (!!(record?.uploadPath) ? '&uploadPath=' + (record?.uploadPath || '') : '');
            if (record?.format === 'uploadName') { // 附加的参数
                uploadPath = uploadPath + '/' + (userData?.hospCode || '') + '/' + dayjs().format('YY_MM') + '&' + (userData?.hospCode || '') + '_' + (currentFile?.name || '');
            }
        } else if (uploadUrl) { // 组件外部传入了则直接取
            uploadPath = uploadUrl;
        } else {
            let nFileType = record?.fileType || fileType || 'optomefile';
            uploadPath = '/uploadFile?fileType=' + nFileType
        }
        let fetchUrl = (envConfig?.WINDOW_HOST || '') + uploadPath;
        fetch(fetchUrl, option)
            .then(function (response) {
                if (response.ok) {
                    console.log('response', response);
                    setUploadLoading(false);
                    return response.text();
                } else {
                    console.log('网络错误，请稍后再试');
                    setUploadLoading(false);
                    return;
                }
            }).then((data) => {
                let res = JSON.parse(data);
                if (!(res && 'errorCode' in res)) {
                    setUploadLoading(false);
                    return;
                };
                if (res.errorCode === '0') {
                    if (fileList && fileList.length > 0) {
                        for (var i = 0; i < fileList.length; i++) {
                            if (fileList[i].uid === currentFile.uid) {
                                fileList[i].filePath = res?.filePath || '';
                                break;
                            }
                        }
                    }
                    // uploadData[record.dataIndex] = fileList;
                    message.success('上传成功');
                } else {
                    if (fileList && fileList.length > 0) {
                        fileList = fileList.filter(item => item.uid !== currentFile.uid); // 删除上传失败的文件
                    }
                    message.error(res?.errorMessage || '上传失败');
                }
                record.fileList = fileList; // 用于判断个数
                setUploadLoading(false);
                record.dataIndex && setFieldsValue({
                    [record.dataIndex]: fileList
                })
            })
            .catch((error) => {
                console.log('上传错误', error);
                message.error('网络错误，请稍后再试！');
                if (fileList && fileList.length > 0) {
                    fileList = fileList.filter(item => item.uid !== currentFile.uid); // 删除上传失败的文件
                }
                record.fileList = fileList; // 用于判断个数
                record.dataIndex && setFieldsValue({
                    [record.dataIndex]: fileList
                })
                setUploadLoading(false);
            })
    };

    // 树节点渲染
    const renderTreeNodes = (data, typeCode) => {
        return data.map((item, index) => {
            if (item && 'children' in item && Array.isArray(item.children)) {
                return (
                    <TreeNode
                        disabled={typeCode === 'TreeSelect' ? true : false}
                        value={item?.value || item?.id || undefined}
                        title={(
                            <span style={{ color: '#666' }}>
                                {item?.title || item?.descripts || ''}
                            </span>
                        )}
                        key={item?.key || (index + 1)}
                        search={(item?.title || item?.descripts || '') + '^' + (item?.descriptsSPCode || '')}
                    >
                        {renderTreeNodes(item?.children || [], typeCode)}
                    </TreeNode>
                );
            }
            return <TreeNode
                value={item?.value || item?.id || undefined}
                title={item?.title || item?.descripts || ''}
                key={item?.key || (index + 1)}
                search={(item?.title || item?.descripts || '') + '^' + (item?.descriptsSPCode || '')}
            />;
        });
    };

    // 修改表单属性 - 栗子【点击查询添加loading属性】
    const modifyFormItemAttr = (dataIndex, value, attrIndex = 'loading') => {
        if (!dataIndex) return;
        const newFilterFormData = filterFormData.map(item =>
            item.dataIndex === dataIndex ? { ...item, [attrIndex]: value } : item
        );
        setFilterFormData(newFilterFormData);
    };

    return (
        <Spin tip={uploadLoading ? '正在上传文件...' : '加载中...'} spinning={uploadLoading || spinLoading}>
            <div className="dynamic-rendering-form">
                <Form
                    name={props?.name || Util.uuid()}
                    className={props?.className || ''}
                    form={form}
                    initialValues={{
                        remember: true,
                    }}
                    autoComplete="off"
                >
                    <Row>
                        {renderFormItem(filterFormData)}
                    </Row>
                </Form>
            </div>
        </Spin >
    );
};

export default forwardRef(DynamicRenderingForm);