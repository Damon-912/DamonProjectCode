/*
 * Create:      柿子
 * CreateDate:  2024/04/25
 * Describe：   公共分页
 * */
import React, { useState, useEffect } from 'react';
import { Select, Input, message, Spin } from 'antd';
import { StepBackwardOutlined, StepForwardOutlined, CaretLeftOutlined, CaretRightOutlined, LoadingOutlined, ReloadOutlined } from '@ant-design/icons';
import { Util } from '@tools';
import './style/index.less';

const PublicPagination = (props) => {
    const propsTotal = props?.total || 0;
    const propsPage = props?.page || 1;
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(10);
    const [pageSizeList, setPageSizeList] = useState([]);

    // 监听总数据变化
    useEffect(() => {
        !propsTotal && setPage(1);
    }, [propsTotal]);

    // 监听总数据变化
    useEffect(() => {
        setPage(propsPage);
    }, [propsPage]);

    useEffect(() => {
        handleInit();
    }, []);

    // 初始化数据
    const handleInit = () => {
        const { size = 'small', customList, additionalList = [], company, defaultPageSize } = props;
        let sizeEnum = {
            small: [10, 20, 30, 50, ...additionalList], // additionalList为扩展条数数组 - 传入示例：[5, 70]
            large: [50, 100, 200, 300, ...additionalList],
        };
        let currentSize = Util.arraySort(customList && Array.isArray(customList) && customList.length > 0 ? customList : sizeEnum[size]);
        let pageSizeList = currentSize && currentSize.map(item => {
            return {
                id: item,
                descripts: item + (company || '条') + '/页'
            }
        })
        setPageSize(defaultPageSize ? String(defaultPageSize) : String(currentSize && currentSize.length > 0 ? currentSize[0] : 10)); // 默认条数处理
        setPageSizeList(pageSizeList);
    };

    // 修改pageSize
    const changePageSize = (e) => {
        if (e.keyCode == '13') {
            let { onChange } = props;
            onChange && onChange(page, pageSize)
        }
    };

    // 点击按钮，切换不同的页签
    const changeCommonPageSize = (name) => {
        let { onChange } = props;
        let nPage = 0;
        if (name === 'home') {
            nPage = 1;
        } else if (name === 'last') {
            nPage = parseInt(page) - 1;
        } else if (name === 'next') {
            if (!isNaN(page) && !Util.isEmpty(page)) {
                nPage = parseInt(page) + 1;
            } else {
                let count = 1;
                nPage = count + 1;
            }
        } else if (name === 'end') {
            nPage = Math.ceil(propsTotal / pageSize);
        } else if (name == 'search') {
            nPage = parseInt(page);
        }
        onChange && onChange(nPage, pageSize);
        setPage(nPage);
    };

    const handleSearchPage = (pPageSize) => {
        let { onChange } = props;
        onChange && onChange(1, pPageSize);
        setPage(1);
        setPageSize(pPageSize);
    }

    //输入页数校验，显示输入数据不能大于当前总页数
    const commonInputChange = (size, e) => {
        let value = e.target.value;
        if (isNaN(value) && !Util.isEmpty(value)) {
            message.error('请输入一个正确的数字！')
            return
        }
        if (value > Math.ceil(propsTotal / size)) {
            message.error('输入页数不能大于当前总页数')
            return
        }
        setPage(value)
    };

    const antIcon = props.loading ? (
        <LoadingOutlined spin={props.loading} className="pp-icon-style" onClick={() => changeCommonPageSize('search')} />
    ) : (
        <ReloadOutlined className="pp-icon-style" onClick={() => changeCommonPageSize('search')} />
    );

    //计算当前页显示的数据
    let pageCount = !Util.isEmpty(page) ? (page == 1 ? 1 : (parseInt(pageSize) * (parseInt(page) - 1) + 1)) : 0;
    let pageSum = !Util.isEmpty(page) ? (page == 1 ? pageSize : (parseInt(page) * parseInt(pageSize))) : 0
    return (
        <div className="public-pagination">
            <div className="flex" style={{ float: 'right' }}>
                <div className="flex-align-items">
                    {props?.completeFlag !== 'N' && ( // 是否显示当前条数记录，默认展示
                        <span>
                            {!Util.isEmpty(propsTotal || 0) ? pageCount : 0}
                            {props.company ? props.company : '条'}
                            到{!Util.isEmpty(propsTotal || 0) ? pageSum : 0}
                            {props.company ? props.company : '条'}记录，
                        </span>
                    )}
                    <span>共{propsTotal || 0}{props.company ? props.company : '条'}</span>
                </div>
                <div className="flex-align-items">
                    <span className="flex-align-items">
                        {page > 1 ? (
                            <>
                                <StepBackwardOutlined className="pp-icon-style" onClick={() => changeCommonPageSize('home')} />
                                <CaretLeftOutlined className="pp-icon-style" onClick={() => changeCommonPageSize('last')} />
                            </>
                        ) : (
                            <>
                                <StepBackwardOutlined className="pp-icon-style pp-icon-disabled" />
                                <CaretLeftOutlined className="pp-icon-style pp-icon-disabled" />
                            </>
                        )}
                    </span>
                    第<Input
                        style={{ width: 50 }}
                        size="small"
                        value={page}
                        onKeyDown={changePageSize}
                        onChange={(e) => commonInputChange(pageSize, e)} />
                    页&nbsp;&nbsp; 共{Math.ceil(propsTotal / pageSize) || 0}页
                    <span className="flex-align-items">
                        {page == (Math.ceil(propsTotal / pageSize) || 1) ? (
                            <>
                                <CaretRightOutlined className="pp-icon-style pp-icon-disabled" />
                                <StepForwardOutlined className="pp-icon-style pp-icon-disabled" />
                            </>
                        ) : (
                            <>
                                <CaretRightOutlined className="pp-icon-style" onClick={() => changeCommonPageSize('next')} />
                                <StepForwardOutlined className="pp-icon-style" onClick={() => changeCommonPageSize('end')} />
                            </>
                        )}
                    </span>
                    <Spin indicator={antIcon} size="small" />
                    <Select
                        style={{ width: props?.size === 'large' ? 96 : 86 }}
                        size="small"
                        className="pp-icon-style"
                        value={pageSize}
                        onSelect={handleSearchPage}
                    >
                        {React.$SelectOptions(pageSizeList)}
                    </Select>
                </div>
            </div>
        </div>
    );
};

export default PublicPagination;