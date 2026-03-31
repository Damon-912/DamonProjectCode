// 数据类图标
const dataClassIcons = ['AreaChartOutlined', 'PieChartOutlined', 'BarChartOutlined', 'DotChartOutlined', 'LineChartOutlined', 'RadarChartOutlined', 'HeatMapOutlined', 'FallOutlined',
    'RiseOutlined', 'StockOutlined', 'BoxPlotOutlined', 'FundOutlined', 'SlidersOutlined'];

// 网站通用图标
const universalIcons = [
    'BulbOutlined', 'AccountBookOutlined', 'AimOutlined', 'AlertOutlined', 'ApartmentOutlined', 'ApiOutlined', 'AppstoreAddOutlined', 'AppstoreOutlined', 'AudioOutlined',
    'AudioMutedOutlined', 'AuditOutlined', 'BankOutlined', 'BarcodeOutlined', 'BarsOutlined', 'BellOutlined', 'BlockOutlined', 'BookOutlined', 'BorderOutlined',
    'BorderlessTableOutlined', 'BranchesOutlined', 'BugOutlined', 'BuildOutlined', 'CalculatorOutlined', 'CalendarOutlined', 'CameraOutlined', 'CarOutlined',
    'CarryOutOutlined', 'CiCircleOutlined', 'CiOutlined', 'ClearOutlined', 'CloudDownloadOutlined', 'CloudOutlined', 'CloudServerOutlined', 'CloudSyncOutlined',
    'CloudUploadOutlined', 'ClusterOutlined', 'CodeOutlined', 'CoffeeOutlined', 'CommentOutlined', 'CompassOutlined', 'CompressOutlined', 'ConsoleSqlOutlined',
    'ContactsOutlined', 'ContainerOutlined', 'ControlOutlined', 'CopyrightOutlined', 'CreditCardOutlined', 'CrownOutlined', 'CustomerServiceOutlined', 'DashboardOutlined', 'DatabaseOutlined', 'DeleteColumnOutlined', 'DeleteRowOutlined', 'DeliveredProcedureOutlined', 'DeploymentUnitOutlined', 'DesktopOutlined', 'DisconnectOutlined',
    'DislikeOutlined', 'DollarOutlined', 'DownloadOutlined', 'EllipsisOutlined', 'EnvironmentOutlined', 'EuroCircleOutlined', 'EuroOutlined', 'ExceptionOutlined',
    'ExpandAltOutlined', 'ExpandOutlined', 'ExperimentOutlined', 'ExportOutlined', 'EyeOutlined', 'EyeInvisibleOutlined', 'FieldBinaryOutlined', 'FieldNumberOutlined',
    'FieldStringOutlined', 'FieldTimeOutlined', 'FileAddOutlined', 'FileDoneOutlined', 'FileExcelOutlined', 'FileExclamationOutlined', 'FileOutlined', 'FileGifOutlined', 'FileImageOutlined', 'FileJpgOutlined', 'FileMarkdownOutlined', 'FilePdfOutlined', 'FilePptOutlined', 'FileProtectOutlined', 'FileSearchOutlined', 'FileSyncOutlined', 'FileTextOutlined', 'FileUnknownOutlined', 'FileWordOutlined', 'FileZipOutlined', 'FilterOutlined', 'FireOutlined', 'FlagOutlined', 'FolderAddOutlined', 'FolderOutlined', 'FolderOpenOutlined', 'FolderViewOutlined', 'ForkOutlined', 'FormatPainterOutlined', 'FrownOutlined', 'FunctionOutlined', 'FundProjectionScreenOutlined', 'FundViewOutlined', 'FunnelPlotOutlined', 'GatewayOutlined', 'GifOutlined', 'GiftOutlined', 'GlobalOutlined', 'GoldOutlined', 'GroupOutlined', 'HddOutlined', 'HeartOutlined', 'HistoryOutlined', 'HolderOutlined', 'HomeOutlined', 'HourglassOutlined', 'IdcardOutlined', 'ImportOutlined', 'InboxOutlined', 'InsertRowAboveOutlined',
    'InsertRowBelowOutlined', 'InsertRowLeftOutlined', 'InsertRowRightOutlined', 'InsuranceOutlined', 'InteractionOutlined', 'KeyOutlined', 'LaptopOutlined', 'LayoutOutlined', 'LikeOutlined', 'LineOutlined', 'LinkOutlined', 'Loading3QuartersOutlined', 'LoadingOutlined', 'LockOutlined', 'MacCommandOutlined', 'MailOutlined', 'ManOutlined', 'MedicineBoxOutlined', 'MehOutlined', 'MenuOutlined', 'MergeCellsOutlined', 'MergeOutlined', 'MessageOutlined', 'MobileOutlined',
    'MoneyCollectOutlined', 'MonitorOutlined', 'MoonOutlined', 'MoreOutlined', 'MutedOutlined', 'NodeCollapseOutlined', 'NodeExpandOutlined', 'NodeIndexOutlined', 'NotificationOutlined', 'NumberOutlined', 'OneToOneOutlined', 'PaperClipOutlined', 'PartitionOutlined', 'PayCircleOutlined', 'PercentageOutlined', 'PhoneOutlined', 'PictureOutlined', 'PlaySquareOutlined', 'PoundCircleOutlined', 'PoundOutlined', 'PoweroffOutlined', 'PrinterOutlined', 'ProductOutlined', 'ProfileOutlined', 'ProjectOutlined', 'PropertySafetyOutlined', 'PullRequestOutlined', 'PushpinOutlined', 'QrcodeOutlined', 'ReadOutlined', 'ReconciliationOutlined', 'RedEnvelopeOutlined', 'ReloadOutlined', 'RestOutlined', 'RobotOutlined', 'RocketOutlined', 'RotateLeftOutlined', 'RotateRightOutlined', 'SafetyCertificateOutlined', 'SafetyOutlined', 'SaveOutlined', 'ScanOutlined', 'ScheduleOutlined', 'SearchOutlined', 'SecurityScanOutlined', 'SelectOutlined', 'SendOutlined', 'SettingOutlined', 'ShakeOutlined', 'ShareAltOutlined', 'ShopOutlined', 'ShoppingCartOutlined', 'ShoppingOutlined', 'SignatureOutlined', 'SisternodeOutlined', 'SkinOutlined', 'SmileOutlined', 'SolutionOutlined', 'SoundOutlined', 'SplitCellsOutlined', 'StarOutlined', 'SubnodeOutlined', 'SunOutlined', 'SwitcherOutlined', 'SyncOutlined', 'TableOutlined', 'TabletOutlined', 'TagOutlined', 'TagsOutlined', 'TeamOutlined', 'ThunderboltOutlined', 'ToTopOutlined', 'ToolOutlined', 'TrademarkCircleOutlined',
    'TrademarkOutlined', 'TransactionOutlined', 'TranslationOutlined', 'TrophyOutlined', 'TruckOutlined', 'UngroupOutlined', 'UnlockOutlined', 'UploadOutlined', 'UsbOutlined',
    'UserAddOutlined', 'UserDeleteOutlined', 'UserOutlined', 'UserSwitchOutlined', 'UsergroupAddOutlined', 'UsergroupDeleteOutlined', 'VerifiedOutlined', 'VideoCameraAddOutlined', 'VideoCameraOutlined', 'WalletOutlined', 'WifiOutlined', 'WomanOutlined'
];

// 菜单图标
const menuIcons = [...universalIcons, ...dataClassIcons];

export {
    dataClassIcons,
    universalIcons,
    menuIcons,
};