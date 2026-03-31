/*
 * 注意：目前不支持export default
 *
 * 使用：React.$xxxx'
 */
import * as https from './https';
import * as other from './other';
import * as packaging from './packaging';
import * as dataProcessing from './dataProcessing'; // 数据处理

export default {
    ...https,
    ...other,
    ...packaging,
    ...dataProcessing,
};