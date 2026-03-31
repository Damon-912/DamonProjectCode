/*
 * Create:      柿子
 * CreateDate:  2026/01/21
 * Describe：   ICD编码映射关系
 * */
import React, { useRef } from 'react';
import SingleTableOperation from '@pages/dynamicRendering/SingleTableOperation';
import AddMappingRelationship from './component/AddMappingRelationship';

const ICDCodeMappingRelationships = (props) => {
    let tableRef = useRef(null);
    let addICDRef = useRef(null);

    const handleQuery = () => {
        tableRef && tableRef.current && tableRef.current.handleQuery();
    };

    const handleAdd = () => {
        let queryParams = tableRef && tableRef.current && tableRef.current.getQueryParams('versionNo');
        addICDRef && addICDRef.current && addICDRef.current.modifyVisible(true, {
            leftDynamicParams: queryParams,
            rightDynamicParams: queryParams,
            saveDynamicParams: queryParams,
        });
    };

    return (
        <div>
            <SingleTableOperation
                {...props}
                ref={tableRef}
                addCallback={handleAdd}
            />

            {/* 新增ICD编码映射关系弹窗 */}
            <AddMappingRelationship
                ref={addICDRef}
                leftQueryCode="02010022"
                leftComponentName="AddICDEncodingMapping"
                leftCardTitle="ICD编码"
                leftColSpan={16}
                rightQueryCode="02010022"
                rightComponentName="AddICDEncodingMappingDetail"
                rightCardTitle="医保ICD编码"
                rightStaticParams={{
                    provinceID: '36',
                    cityID: '371'
                }}
                cancelResetFlag="Y"
                saveCode="02010023"
                handleQuery={handleQuery}
            />
        </div>
    )
};

export default ICDCodeMappingRelationships;