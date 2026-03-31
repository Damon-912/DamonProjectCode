/*
  * Purpose：    处理table查询接口返回数据
  * Params：     参数
    res [对象] 接口返回数据
    dataIndex [string] key值需要赋值对象对于的哪个字段
    startNum [number] key值从几开始向上累加
  * */
export const processingTableRequestData = (res, dataIndex, startNum = 1) => {
  let data = res && 'result' in res && res.result && Object.prototype.toString.call(res.result) === '[object Object]' ? (
    res.result && 'rows' in res.result && res.result.rows ? res.result.rows : (
      res.result && 'Data' in res.result && res.result.Data ? res.result.Data : (
        res.result && 'data' in res.result && res.result.data ? res.result.data : []))) : (res?.result || res?.data || res?.Data || []);
  return Array.isArray(data) ?
    data.map((item, index) => ({
      ...item,
      key: dataIndex && dataIndex in item && item[dataIndex] ? item[dataIndex] : String(index + startNum)
    })) : [];
};