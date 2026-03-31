/*
 * Create:      柿子
 * CreateDate:  2024/04/26
 * Describe：   公共table列表
 * */
import React, { createContext, useContext, useState, useEffect, useRef, useCallback, forwardRef, useImperativeHandle } from 'react';
import { Table, Tooltip, message, Input, Select, InputNumber, Switch, Checkbox, DatePicker, TimePicker } from 'antd';
import { Util } from '@tools';
import { dayFormat, timeFormat, dateFormat } from '@tools/moment';
import dayjs from 'dayjs';
import PublicPagination from './PublicPagination';
import PublicColumnAuthority from './PublicColumnAuthority';
import {
    closestCenter,
    DndContext,
    DragOverlay,
    PointerSensor,
    useSensor,
    useSensors,
} from '@dnd-kit/core';
import { restrictToHorizontalAxis } from '@dnd-kit/modifiers';
import {
    arrayMove,
    horizontalListSortingStrategy,
    SortableContext,
    useSortable,
} from '@dnd-kit/sortable';

const { TextArea } = Input;

// 自定义输入框
const CustomRender = React.memo(props => {
    const propsValue = props?.value || undefined;
    const typeCode = props?.typeCode || 'Input';
    const item = props?.columnItem || {};
    const selectData = props?.selectData || {};
    const [inputValue, setInputValue] = useState(propsValue);

    const handleDebounceChange = Util.debounce(e => {
        setInputValue(e);
    });

    useEffect(() => {
        setInputValue(propsValue);
    }, [propsValue]);

    useEffect(() => {
        if (inputValue !== propsValue) {
            props && 'onChange' in props && props.onChange(inputValue);
        }
    }, [inputValue]);

    switch (typeCode) {
        case 'inputNumber': // 数字框
        case 'InputNumber':
            return (
                <InputNumber
                    min={item?.min || Number.MAX_SAFE_INTEGER}
                    max={item?.max || Number.MAX_SAFE_INTEGER}
                    style={{ width: item?.inputWidth || '95%' }}
                    placeholder={item?.placeholder || '请输入'}
                    allowClear={!!(item?.disabled === 'Y')}
                    disabled={!!(item?.disabled === 'Y' || item?.disabled === true)}
                    value={inputValue}
                    onChange={e => setInputValue(e.target.value)}
                    onClick={(e) => React.$stopPropagation(e)}
                />
            );
        case 'TextArea': // 多行录入
            return (
                <TextArea
                    style={{ width: item?.inputWidth || '95%' }}
                    placeholder={item?.placeholder || '请输入'}
                    allowClear={!!(item?.disabled === 'Y')}
                    disabled={!!(item?.disabled === 'Y' || item?.disabled === true)}
                    value={inputValue}
                    onChange={e => setInputValue(e.target.value)}
                    onClick={(e) => React.$stopPropagation(e)}
                />
            )
        case 'Select': // 下拉框
        case 'SelectMultiple': // 下拉框多选
        case 'SelectBox':
            return (
                <Select
                    showSearch
                    optionFilterProp="search"
                    style={{ width: item?.inputWidth || '95%' }}
                    placeholder={item?.placeholder || '请选择'}
                    allowClear={!!(item?.disabled !== 'N')}
                    disabled={!!(item?.disabled === 'Y' || item?.disabled === true)}
                    mode={item?.typeCode === 'SelectMultiple' || item?.typeCode === 'SelectBox' ? 'multiple' : (item && item.mode ? item.mode : null)} // mode="multiple" 多选
                    value={inputValue}
                    onChange={e => handleDebounceChange(e)}
                    onClick={(e) => React.$stopPropagation(e)}
                >
                    {React.$SelectOptions(item?.detailItem || (
                        selectData && item.dataIndex in selectData && Array.isArray(selectData[item.dataIndex]) ? selectData[item.dataIndex] : (
                            item && 'linkMethod' in item && item.linkMethod && selectData && item.linkMethod in selectData && Array.isArray(selectData[item.linkMethod]) ? (
                                selectData[item.linkMethod]
                            ) : []
                        )))}
                </Select>
            );
        case 'switch':
        case 'Switch': // 开关
            return (
                <Switch
                    checkedChildren={item?.checkedChildren || '是'}
                    unCheckedChildren={item?.unCheckedChildren || '否'}
                    disabled={!!(item?.disabled === 'Y' || item?.disabled === true)}
                    checked={inputValue === 'Y' ? true : false}
                    onChange={e => handleDebounceChange(e ? 'Y' : 'N')}
                    onClick={(e) => React.$stopPropagation(e)}
                />
            )
        case 'Checkbox':
        case 'CheckBox': // 复选框
            return (
                <Checkbox
                    disabled={!!(item?.disabled === 'Y' || item?.disabled === true)}
                    checked={inputValue === 'Y' ? true : false}
                    onChange={e => handleDebounceChange(e.target.checked ? 'Y' : 'N')}
                    onClick={(e) => React.$stopPropagation(e)}
                />
            );
        case 'Date':
        case 'DatePicker':
            return (
                <DatePicker
                    allowClear={!!(item?.disabled !== 'N')}
                    disabled={!!(item?.disabled === 'Y' || item?.disabled === true)}
                    style={{ width: item?.inputWidth || '95%' }}
                    value={inputValue ? dayjs(inputValue) : null}
                    onChange={e => handleDebounceChange(e ? dayjs(e).format(dayFormat) : undefined)}
                    onClick={(e) => React.$stopPropagation(e)}
                />
            );
        case 'DateTime':
            return (
                <DatePicker
                    showTime={true}
                    allowClear={!!(item?.disabled !== 'N')}
                    disabled={!!(item?.disabled === 'Y' || item?.disabled === true)}
                    style={{ width: item?.inputWidth || '95%' }}
                    value={inputValue ? dayjs(inputValue) : null}
                    onChange={e => handleDebounceChange(e ? dayjs(e).format(dateFormat) : undefined)}
                    onClick={(e) => React.$stopPropagation(e)}
                />
            );
        case 'Time':
            let tFormat = item?.format || timeFormat;
            return (
                <TimePicker
                    format={tFormat}
                    allowClear={!!(item?.disabled !== 'N')}
                    disabled={!!(item?.disabled === 'Y' || item?.disabled === true)}
                    style={{ width: item?.inputWidth || '95%' }}
                    value={inputValue ? dayjs(inputValue) : undefined}
                    onChange={e => handleDebounceChange(e ? dayjs(e).format(tFormat) : undefined)}
                    onClick={(e) => React.$stopPropagation(e)}
                />
            );
        default:
            return (
                <Input
                    style={{ width: item?.inputWidth || '95%' }}
                    placeholder={item?.placeholder || '请输入'}
                    allowClear={!!(item?.disabled === 'Y')}
                    disabled={!!(item?.disabled === 'Y' || item?.disabled === true)}
                    value={inputValue}
                    onChange={e => setInputValue(e.target.value)}
                    onClick={(e) => React.$stopPropagation(e)}
                />
            );
    };
});

const DragIndexContext = createContext({
    active: -1,
    over: -1,
});

const dragActiveStyle = (dragState, id) => {
    const { active, over, direction } = dragState;
    let style = {};
    if (active && active === id) {
        style = {
            backgroundColor: 'gray',
            opacity: 0.5,
        };
    }
    else if (over && id === over && active !== over) {
        style =
            direction === 'right' ? {
                borderRight: '1px dashed gray',
            } : {
                borderLeft: '1px dashed gray',
            };
    }
    return style;
};

const TableBodyCell = (props) => {
    const dragState = useContext(DragIndexContext);
    return (
        <td
            {...props}
            style={{
                ...props.style,
                ...dragActiveStyle(dragState, props.id),
            }}
        />
    );
};

const TableHeaderCell = (props) => {
    const dragState = useContext(DragIndexContext);
    const { attributes, listeners, setNodeRef, isDragging } = useSortable({
        id: props.id,
    });
    const style = {
        ...props.style,
        cursor: 'move',
        ...(isDragging
            ? {
                position: 'relative',
                zIndex: 9999,
                userSelect: 'none',
            }
            : {}),
        ...dragActiveStyle(dragState, props.id),
    };
    return <th {...props} ref={setNodeRef} style={style} {...attributes} {...listeners} />;
};

const PublicTablePagination = (props, ref) => {
    let timer = null;
    let columnAuthorityRef = useRef(null);
    const tableParams = props?.param || {};
    const propsColumns = tableParams?.columns || [];
    const propsSelectData = tableParams?.selectData || {};
    const propsTableData = tableParams?.data || [];
    const [columns, setColumns] = useState([]);
    const [tableData, setTableData] = useState([]);
    const [filterColumns, setFilterColumns] = useState([]);
    const [selectData, setSelectData] = useState({});
    const [dragIndex, setDragIndex] = useState({
        active: -1,
        over: -1,
    });

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        handleRowSelection
    }));

    useEffect(() => {
        if (JSON.stringify(columns) !== JSON.stringify(propsColumns) || JSON.stringify(selectData) !== JSON.stringify(propsSelectData)) {
            if (JSON.stringify(columns) !== JSON.stringify(propsColumns)) {
                setColumns(propsColumns);
            }
            if (JSON.stringify(selectData) !== JSON.stringify(propsSelectData)) {
                setSelectData(propsSelectData)
            };
            handleDefaultAssignment();
        };
    }, [propsColumns, propsSelectData]);

    useEffect(() => {
        if (JSON.stringify(tableData) !== JSON.stringify(propsTableData)) {
            setTableData(propsTableData);
        };
    }, [propsTableData]);

    const handleDefaultAssignment = () => {
        let filterColumns = Util.customDeepCopy(propsColumns);
        for (let i = 0; i < filterColumns.length; i++) {
            // 其他参数
            let additionalParameters = Util.getObjByUrlStr(filterColumns[i]?.params || '');
            if (additionalParameters && Object.prototype.toString.call(additionalParameters) === '[object Object]' && JSON.stringify(additionalParameters) !== '{}') {
                for (let otherKey in additionalParameters) {
                    filterColumns[i][otherKey] = additionalParameters[otherKey];
                }
            }
            let item = filterColumns[i];
            let index = i;
            let currentKey = String(index + 1);
            filterColumns[i].key = currentKey;
            filterColumns[i].fixed = item.fixed === 'L' ? 'left' : (item.fixed === 'R' ? 'right' : (item?.fixed || undefined));
            filterColumns[i].ellipsis = item && 'ellipsis' in item && (item?.ellipsis === 'true' || item?.ellipsis === 'Y') ? item.ellipsis : false;
            filterColumns[i].dataIndex = item?.dataIndex || item?.code || '';
            filterColumns[i].title = item?.title || item?.descripts || item?.label || '';
            filterColumns[i].width = !isNaN(parseInt(item?.width)) ? parseInt(item?.width || 100) + 'px' : '100px';
            filterColumns[i].onHeaderCell = column => ({
                id: `${currentKey}`,
                width: column && 'width' in column && column.width && !isNaN(column.width) ? parseInt(column.width) : 100,
                onResize: handleResize(index),
            });
            if (item?.isRender !== 'N') { // 行内编辑避免重新渲染
                filterColumns[i].render = item && 'render' in item && item.tooltip !== 'Y' ? item.render : (text, record, index) => getInput(text, record, index, item);
            };
            if (tableParams?.colDndFlag === 'Y') { // 列拖拽标志
                filterColumns[i].onCell = () => ({
                    id: `${currentKey}`,
                });
            }
        }
        setFilterColumns(filterColumns);
    };

    const getInput = (text, record, index, item) => {
        if (item && 'typeCode' in item && item.typeCode && item?.renderFlag !== 'N' && record?.renderFlag !== 'N') { // 当存在typeCode则根据typeCode渲染对应输入域
            return (
                <CustomRender
                    typeCode={item?.typeCode || 'Input'}
                    columnItem={item}
                    value={record[item.dataIndex]}
                    selectData={propsSelectData}
                    onChange={(e) => handleInputChange(e, index, item.dataIndex, record)}
                />
            );
        } else if ((text === 'Y' || text === 'N') && item?.autoTransform !== 'N') { // Y/N转换
            let config = {
                'Y': '是',
                'N': '否'
            };
            return config[text];
        } else if (item?.tooltip === 'Y') { // 默认展示Tooltip，特殊处理为N则不展示Tooltip
            return (
                <Tooltip title={text}>
                    <span className="common-ellipsis" style={{ width: '100%', display: 'block' }}>{text}</span>
                </Tooltip>
            );
        } else if (item?.ellipsisFlag === 'Y') {
            return (
                <span className="common-ellipsis" style={{ width: '100%', display: 'block' }}>{text}</span>
            )
        } else {
            return text;
        }
    };

    // 输入域修改 - 提供给父组件去修改，公共组件不做处理只作展示
    const handleInputChange = useCallback((val, index, dataIndex, record) => {
        props && 'onChange' in props && props.onChange(val, index, dataIndex, record);
    });

    const handleResize = index => (e, { size }) => {
        let componentName = tableParams?.componentName || '';
        if (componentName) {
            let nFilterColumns = filterColumns;
            nFilterColumns[index].width = parseInt(size?.width || nFilterColumns[index]?.width || 100);
            setFilterColumns(nFilterColumns);
            handleDebounce(componentName);
        }
    };

    // 只保留最后一次操作数据
    const handleDebounce = (componentName) => {
        if (timer) {
            clearTimeout(timer);
            timer = null;
        }
        timer = setTimeout(() => {
            handleSaveWidthByUser(componentName)
        }, 500);
    };

    // 按用户保存拖拽后的宽度
    const handleSaveWidthByUser = async (componentName) => {
        try {
            message.success('列宽修改成功');
        } catch (error) {
            console.log(error)
        }
    };

    // 双击表头触发表头数据维护
    const handleRowSelection = () => {
        return {
            onDoubleClick: () => {
                columnAuthorityRef && columnAuthorityRef.current && columnAuthorityRef.current.modifyVisible && columnAuthorityRef?.current?.modifyVisible(true);
            },
        };
    };

    const sensors = useSensors(
        useSensor(PointerSensor, {
            activationConstraint: {
                distance: 1,
            },
        }),
    );

    // 拖拽结束
    const handleDragEnd = ({ active, over }) => {
        if (active.id !== over?.id) {
            setFilterColumns((prevState) => {
                const activeIndex = prevState.findIndex((i) => i.key === active?.id);
                const overIndex = prevState.findIndex((i) => i.key === over?.id);
                const nColumns = arrayMove(prevState, activeIndex, overIndex);
                // 回调更新拖拽数据
                props && 'onDragEnd' in props && props.onDragEnd(nColumns);
                return nColumns;
            });
        }
        setDragIndex({
            active: -1,
            over: -1,
        });
    };

    const handleDragOver = ({ active, over }) => {
        const activeIndex = filterColumns.findIndex((i) => i.key === active.id);
        const overIndex = filterColumns.findIndex((i) => i.key === over?.id);
        setDragIndex({
            active: active.id,
            over: over?.id,
            direction: overIndex > activeIndex ? 'right' : 'left',
        });
    };
    const isColumnModal = 'componentName' in tableParams && tableParams.componentName && props && 'getColumns' in props && props.getColumns ? true : false;
    const scrollY = tableParams && 'y' in tableParams && tableParams.y && tableParams?.y !== 'none' && tableParams?.y !== 'N' && tableParams?.y !== 'false' ? tableParams.y : '';
    // table属性
    const tableAttr = {
        bordered: tableParams?.bordered != undefined ? tableParams?.bordered : true,
        pagination: false,
        rowKey: (row) => {
            return tableParams && 'rowKey' in tableParams && tableParams.rowKey ? row[tableParams.rowKey] : (row?.key || row?.id || '');
        },
        size: tableParams?.tableSize || 'middle',
        virtual: tableParams?.virtual || false, // 支持虚拟列表
        dataSource: tableData,
        columns: filterColumns,
        loading: tableParams?.loading || false,
        className: tableParams?.tableClassName || '',
        style: {
            height: scrollY && tableParams && 'height' in tableParams && tableParams.height ? tableParams.height : 'auto'
        },
        scroll: {
            x: tableParams && 'x' in tableParams && tableParams.x ? parseInt(tableParams.x) : null,
            y: scrollY ? parseInt(scrollY) : null
        },
        rowSelection: props.rowSelection ? props.rowSelection : null,
        onRow: props.onRow ? (record, index) => props.onRow(record, index) : null,
        rowClassName: props.rowClassName ? props.rowClassName : '',
        onHeaderRow: props.onClickHeadRowPublic ? props.onClickHeadRowPublic : (isColumnModal ? handleRowSelection : () => { }),
    }
    return (
        <div className={[tableParams?.className || '', scrollY ? 'common-table-body-height' : ''].join(' ')}>
            {tableParams?.colDndFlag === 'Y' ? ( // 列拖拽标志
                <DndContext
                    sensors={sensors}
                    modifiers={[restrictToHorizontalAxis]}
                    onDragEnd={handleDragEnd}
                    onDragOver={handleDragOver}
                    collisionDetection={closestCenter}
                >
                    <SortableContext items={filterColumns.map((i) => i.key)} strategy={horizontalListSortingStrategy}>
                        <DragIndexContext.Provider value={dragIndex}>
                            <Table
                                {...tableAttr}
                                components={{
                                    header: {
                                        cell: TableHeaderCell,
                                    },
                                    body: {
                                        cell: TableBodyCell,
                                    },
                                }}
                            />
                        </DragIndexContext.Provider>
                    </SortableContext>
                    <DragOverlay>
                        <th
                            style={{
                                backgroundColor: 'gray',
                                padding: 8,
                            }}
                        >
                            {filterColumns[filterColumns.findIndex((i) => i.key === dragIndex.active)]?.descripts || filterColumns[filterColumns.findIndex((i) => i.key === dragIndex.active)]?.title || ''}
                        </th>
                    </DragOverlay>
                </DndContext>
            ) : (
                <Table {...tableAttr} />
            )}
            {props && 'compilePage' in props && props.compilePage ? (
                <PublicPagination
                    loading={tableParams?.loading || false}
                    page={tableParams?.page || 0}
                    total={tableParams?.total || 0}
                    size={tableParams?.size || 'small'}
                    completeFlag={props?.isComplete || 'Y'}
                    defaultPageSize={tableParams?.defaultPageSize || ''}
                    onChange={props?.compilePage || null}
                />
            ) : ''}
            {isColumnModal ? (
                <PublicColumnAuthority
                    configType="C"
                    clientWidth="800px"
                    ref={columnAuthorityRef}
                    getColumns={props?.getColumns || null}
                    componentName={tableParams.componentName}
                />
            ) : ''}
        </div>
    );
};

export default forwardRef(PublicTablePagination);