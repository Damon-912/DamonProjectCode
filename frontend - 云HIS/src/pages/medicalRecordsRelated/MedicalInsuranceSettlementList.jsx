/*
 * Create:      柿子
 * CreateDate:  2026/02/10
 * Describe：   医保结算清单信息
 * */
import React, { useRef } from 'react';
import SingleTableOperation from '@pages/dynamicRendering/SingleTableOperation';
import SettlementStatement from './component/SettlementStatement';

const MedicalInsuranceSettlementList = (props) => {
    let tableRef = useRef(null);
    let settlementRef = useRef(null);

    // 结算清单预览
    const handlePreviewSettlement = (record, e) => {
        React.$stopPropagation(e);
        settlementRef && settlementRef.current && settlementRef.current.modifyVisible && settlementRef.current.modifyVisible(true, record);
    }

    const operationObj = {
        width: 120,
        title: '操作',
        fixed: 'right',
        align: 'center',
        key: 'operation',
        render: (text, record) => (
            <span className="common-record-span" onClick={(e) => handlePreviewSettlement(record, e)}>
                结算清单预览
            </span>
        ),
    };
    return (
        <div>
            <SingleTableOperation
                {...props}
                customOperationObj={operationObj}
                ref={tableRef}
            />

            <SettlementStatement ref={settlementRef} />
        </div>
    )
};

export default MedicalInsuranceSettlementList;