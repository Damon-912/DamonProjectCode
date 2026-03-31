const staticSelectData = {
    // 性别
    gender: [{
        id: '1',
        descripts: '男',
    }, {
        id: '2',
        descripts: '女',
    }],

    // 婚姻状况
    marital: [{
        id: '1',
        descripts: '未婚',
    }, {
        id: '2',
        descripts: '已婚',
    }, {
        id: '3',
        descripts: '丧偶',
    }, {
        id: '4',
        descripts: '离婚',
    }, {
        id: '9',
        descripts: '其他',
    }],

    // 入院途径
    admissionRoute: [{
        id: '1',
        descripts: '急诊',
    }, {
        id: '2',
        descripts: '门诊',
    }, {
        id: '3',
        descripts: '其他医疗机构转入',
    }, {
        id: '9',
        descripts: '其他',
    }],

    // 血型
    bloodType: [{
        id: '1',
        descripts: 'A',
    }, {
        id: '2',
        descripts: 'B',
    }, {
        id: '3',
        descripts: 'O',
    }, {
        id: '4',
        descripts: 'AB',
    }, {
        id: '5',
        descripts: '不详',
    }, {
        id: '6',
        descripts: '未查',
    }],

    // Rh血型文本
    rhBloodType: [{
        id: '1',
        descripts: '阴性',
    }, {
        id: '2',
        descripts: '阳性',
    }, {
        id: '3',
        descripts: '不详',
    }, {
        id: '4',
        descripts: '未查',
    }],

    // 病例分型
    caseType: [{
        id: 'A',
        descripts: '一般',
    }, {
        id: 'B',
        descripts: '急',
    }, {
        id: 'C',
        descripts: '疑难',
    }, {
        id: 'D',
        descripts: '危重'
    }],

    // 31天内再住院计划
    readmissionPlan: [{
        id: '1',
        descripts: '无',
    }, {
        id: '2',
        descripts: '有'
    }],

    // 病案质量
    recordQuality: [{
        id: '1',
        descripts: '甲',
    }, {
        id: '2',
        descripts: '乙',
    }, {
        id: '3',
        descripts: '丙'
    }],

    // 临床路径病例
    clinicalPathway: [{
        id: '1',
        descripts: '是',
    }, {
        id: '2',
        descripts: '否'
    }],

    // 药物过敏
    drugAllergy: [{
        id: '1',
        descripts: '无',
    }, {
        id: '2',
        descripts: '有'
    }],

    // 死亡患者尸检
    autopsy: [{
        id: '1',
        descripts: '是',
    }, {
        id: '2',
        descripts: '否'
    }],

    // 付款方式
    paymentMethod: [{
        id: '01',
        descripts: '城镇职工基本医疗保险',
    }, {
        id: '02',
        descripts: '城镇居民基本医疗保险',
    }, {
        id: '03',
        descripts: '新型农村合作医疗',
    }, {
        id: '04',
        descripts: '贫困救助',
    }, {
        id: '05',
        descripts: '商业医疗保险',
    }, {
        id: '06',
        descripts: '全公费',
    }, {
        id: '07',
        descripts: '全自费',
    }, {
        id: '08',
        descripts: '其他社会保险',
    }, {
        id: '99',
        descripts: '其他'
    }],

    // 离院方式
    leaveHospitalMethod: [{
        id: '1',
        descripts: '医嘱离院',
    }, {
        id: '2',
        descripts: '医嘱转院，拟接收机构名称',
    }, {
        id: '3',
        descripts: '医嘱转社区卫生服务机构/乡镇卫生院，拟接机构名称',
    }, {
        id: '4',
        descripts: '非医嘱离院',
    }, {
        id: '5',
        descripts: '死亡',
    }, {
        id: '9',
        descripts: '其他',
    }],

    // 医保支付方式
    insurancePaymentMethod: [{
        id: '1',
        descripts: '按项目',
    }, {
        id: '2',
        descripts: '单病种',
    }, {
        id: '3',
        descripts: '按病种分值',
    }, {
        id: '4',
        descripts: '疾病诊断相关分组（DRG）',
    }, {
        id: '5',
        descripts: '按床日'
    }, {
        id: '6',
        descripts: '按人头',
    }, {
        id: '7',
        descripts: '其他'
    }],

    // 住院医疗类型
    medicalType: [{
        id: '1',
        descripts: '住院',
    }, {
        id: '2',
        descripts: '日间手术',
    }],

    // 治疗类别
    treatmentType: [{
        id: '1',
        descripts: '西医',
    }, {
        id: '2',
        descripts: '中医（2.1 中医  2.2民族医）'
    }, {
        id: '3',
        descripts: '中西医'
    }]
}

export {
    staticSelectData
}