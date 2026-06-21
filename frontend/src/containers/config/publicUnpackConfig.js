// 公共不打包配置 script标签引用 这样可以在发布的时候实时修改一些参数，不用重新打包部署
const publicUnpackConfig = {
    queryIP: ' 172.18.100.85', // 查询ip
    productIP: ' 172.18.100.85' // 增删改ip
}