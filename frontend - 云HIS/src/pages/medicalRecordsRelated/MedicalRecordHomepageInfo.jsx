/*
 * Create:      柿子
 * CreateDate:  2026/01/22
 * Describe：   医保病案首页信息
 * */
import React, { useRef } from 'react';
import SingleTableOperation from '@pages/dynamicRendering/SingleTableOperation';
import MedicalRecordFrontPage from './component/MedicalRecordFrontPage';

const MedicalRecordHomepageInfo = (props) => {
    let tableRef = useRef(null);
    let emrRef = useRef(null);

    // 病案首页预览
    const handlePreviewHomepage = (record, e) => {
        React.$stopPropagation(e);
        emrRef && emrRef.current && emrRef.current.modifyVisible && emrRef.current.modifyVisible(true, record);
    }

    const operationObj = {
        width: 100,
        title: '操作',
        fixed: 'right',
        align: 'center',
        key: 'operation',
        render: (text, record) => (
            <span className="common-record-span" onClick={(e) => handlePreviewHomepage(record, e)}>
                预览首页
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

            <MedicalRecordFrontPage ref={emrRef} />
        </div>
    )
};

export default MedicalRecordHomepageInfo;