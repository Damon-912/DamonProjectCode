import * as XLSX from 'xlsx';
import { envConfig } from '@envConfig';

const getColumnName = (index) => {
    let columnName = '';
    while (index >= 0) {
        columnName = String.fromCharCode(65 + (index % 26)) + columnName;
        index = Math.floor(index / 26) - 1;
    }

    return columnName;
};

const excelJS = {
    // 导入excel
    importExcel(file, type) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            // 读取Excel文件
            reader.onload = (e) => {
                const data = new Uint8Array(e.target.result);
                const workbook = XLSX.read(data, { type: 'array', cellDates: true });
                // 获取第一个工作表
                const worksheetName = workbook.SheetNames[0];
                const worksheet = workbook.Sheets[worksheetName];
                // 将工作表转换为JSON对象数组
                const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 'A', blankrows: false, defval: '' });
                jsonData.forEach(row => {
                    Object.keys(row).forEach(key => {
                        if (row[key] instanceof Date) { // 日期处理
                            // 获取本地时间偏移量并转为分钟
                            let timezoneOffset = row[key].getTimezoneOffset() * 60000;
                            // 创建新的 Date 对象，减去时区偏移量
                            let localDate = new Date(row[key].getTime() - timezoneOffset);
                            let year = localDate.getFullYear();
                            let month = (localDate.getMonth() + 1).toString().padStart(2, '0');
                            let date = localDate.getDate().toString().padStart(2, '0');
                            row[key] = `${year}-${month}-${date}`;
                        }
                    });
                });
                if (type === 'keyVal') { // 第一行作为数据的key值，其他的数据作为val值，返回成列表需要的数据格式。栗子：[{dataIndex: 'code', width: '150px'}]
                    let [columnData, ...dataRows] = jsonData;
                    let tableData = dataRows.map(row => {
                        return Object.fromEntries(Object.entries(columnData).map(([key, value]) => [value, row[key]]));
                    });
                    resolve(tableData);
                } else {
                    resolve(jsonData);
                }
            };
            reader.onerror = () => {
                reject(reader.error);
            };
            reader.readAsArrayBuffer(file);
        });
    },

    // 导出 Excel
    exportExcel(headers, data, name = '导出表格数据', arr, format, sheetName, callback) {
        try {
            let fileName = name + '.' + (format || 'xlsx');
            let headerData = []
            for (var i = 0; i < headers.length; i++) {
                headerData.push({ wpx: parseInt(headers[i].width || 100) })
            }
            // 单元格的大小
            let wpxArr = arr && arr.length > 0 ? arr : headerData;
            const hasParentTitle = headers.some(header => 'parentTitle' in header);
            let _headers = {};
            let _subHeaders = {};
            let merges = [];
            if (!hasParentTitle) { // 只有一级标题 - 按之前的逻辑走
                _headers = headers
                    .map((item, i) => Object.assign({}, {
                        dataIndex: item.dataIndex,
                        title: typeof (item.title) === 'string' ? item.title : item.descripts,
                        position: getColumnName(i) + '1'
                    }))
                    .reduce((prev, next) => Object.assign({}, prev, { [next.position]: { dataIndex: next.dataIndex, v: next.title } }), {});
            } else { // 二级表头，当有 parentTitle等于title时，合并单元格，否则不合并
                let currentParentTitle = '';
                let mergeStartIndex = 0;
                for (let i = 0; i < headers.length; i++) {
                    let title = typeof (headers[i]?.title) === 'string' ? headers[i].title : (headers[i]?.descripts || '');
                    let parentTitle = headers[i]?.parentTitle || '';
                    if (parentTitle && title !== parentTitle) {
                        if (currentParentTitle !== parentTitle) {
                            merges.push({ s: { r: 0, c: mergeStartIndex }, e: { r: 0, c: i - 1 } });
                            _headers[getColumnName(i) + '1'] = { v: parentTitle, s: { font: { bold: true }, fill: 'FF0000' } };
                            mergeStartIndex = i;
                        }
                        currentParentTitle = parentTitle;
                        _subHeaders[getColumnName(i) + '2'] = { v: title, s: { font: { bold: true }, fill: 'FF0000' } };
                    } else if (!parentTitle || title === parentTitle) {
                        merges.push({ s: { r: 0, c: i }, e: { r: 1, c: i } });
                        _headers[getColumnName(i) + '1'] = { v: title, s: { font: { bold: true }, fill: 'FF0000' } };
                        currentParentTitle = '';
                    }
                }
                // 检查最后一个父标题是否需要合并
                if (mergeStartIndex < headers.length) {
                    merges.push({ s: { r: 0, c: (mergeStartIndex) }, e: { r: 0, c: (headers.length - 1) } });
                    currentParentTitle = '';
                }
            }
            const outputHeaders = Object.assign({}, _headers, _subHeaders);
            const _data = data
                .map((item, i) => headers.map((headerItem, j) => Object.assign({}, {
                    content: item[headerItem.dataIndex],
                    position: getColumnName(j) + (hasParentTitle ? (i + 3) : (i + 2))
                })))
                // 对刚才的结果进行降维处理（二维数组变成一维数组）
                .reduce((prev, next) => prev.concat(next))
                // 转换成 worksheet 需要的结构
                .reduce((prev, next) => Object.assign({}, prev, { [next.position]: { v: next.content } }), {});
            // 合并 headers 和 data
            const output = Object.assign({}, outputHeaders, _data);
            // 获取所有单元格的位置
            const outputPos = Object.keys(output);
            // 计算出范围 ,["A1",..., "H2"]
            const ref = `${outputPos[0]}:${outputPos[outputPos.length - 1]}`;
            // 构建 workbook 对象
            const wb = {
                SheetNames: [sheetName || 'mySheet'],
                Sheets: {
                    [sheetName || 'mySheet']: Object.assign(
                        {},
                        output,
                        {
                            '!ref': ref,
                            '!cols': wpxArr,
                            '!merges': merges,
                        },
                    ),
                },
            };

            XLSX.writeFile(wb, fileName, (err) => {
                if (err) {
                    message.error(err)
                }
            });
        } catch (error) {
            console.log('导出异常', error);
        }
        callback && typeof (callback) === 'function' && callback();
    },

    // 后台下载，前端用iframe链接地址
    downloadExcel(url, fn) {
        if (!url || (Array.isArray(url) && url.length === 0)) {
            console.warn('没有提供可供下载的有效URL！');
            return;
        }
        if (Array.isArray(url) && url.length > 0) {
            for (let i = 0; i < url.length; i++) {
                this.downloadSingleExcel(url[i], fn, i, url.length);
            }
        } else if (url) {
            this.downloadSingleExcel(url, fn);
        }
    },

    // 下载单个
    downloadSingleExcel(url, fn, currentIndex, totalLen) {
        if (!url) {
            message.error('下载异常！URL链接为空，请稍后重试。');
            return;
        }
        try {
            var iframeElement = document.createElement('iframe');
            iframeElement.src = (envConfig?.WINDOW_HOST || '') + url;
            iframeElement.style.display = 'none';
            document.body.appendChild(iframeElement);
            if (totalLen && typeof totalLen === 'number' && typeof currentIndex === 'number' && currentIndex !== null && currentIndex !== undefined && currentIndex !== '') {
                if ((totalLen.length - 1 === currentIndex)) {
                    fn && fn(); // 在满足条件时触发回调函数
                }
            } else {
                fn && fn();
            }
            // 防止下载两次
            setTimeout(function () {
                document.body.removeChild(iframeElement);
            }, 1000);
        } catch (error) {
            console.error('下载Excel时发生错误:', error);
        }
    },
}

export { excelJS };