import React from 'react';
import { Link } from 'react-router-dom';
import { message, Spin, Menu, Icon } from 'antd';
import store from '../../store';
import PropTypes from 'prop-types'
import StaticRouterData from '../../routers/StaticRouterData';
import './style/index.less';
const { SubMenu } = Menu;

export default class Menus extends React.Component {
	constructor() {
		super();
		this.state = {
			openKeys: [],
			selectedKeys: [],
			RouterData: [],
			MenusData: [],
			filterMenusData: [],
			showLoading: true,
			defaultLanguage: 'CN',
		}
	};

	componentDidMount() {
		// 初始化数据
		this.handleSelectedKeys();
		this.handleSelect();
		this.props.onRef(this);
		// 当地址栏发生改变的时候默认选中相对应的菜单
		window.addEventListener('hashchange', () => {
			this.handleSelectedKeys();
		})
	};

	componentWillReceiveProps(props) {
		if (props.menusData !== this.state.MenusData) {
			this.setState({ MenusData: props.menusData, filterMenusData: props.menusData });
		}
		if (props.routerData !== this.state.RouterData) {
			this.setState({ RouterData: props.routerData });
		}
		if (props.defaultLanguage !== this.state.defaultLanguage) {
			this.setState({ defaultLanguage: props.defaultLanguage });
		}
	};

	componentWillUnmount() {
		// 组件销毁前将静止让setState修改state的状态
		this.setState = (state, callback) => { return; }
		// 组件销毁前清除监听
		window.removeEventListener('hashchange', this.handleSelectedKeys);
	};

	compileShowLoading() {
		this.setState({ showLoading: false });
	};

	clearData = () => {
		this.setState({
			openKeys: [],
			selectedKeys: [],
		})
	};

	// 修改菜单类型
	compileMuneType() {
		let history = this.context.router.history;
		history.push('/001');
	};

	handleSelectedKeys() {
		// 防止页面刷新侧边栏又初始化了
		var path = '';
		const pathname = window.location.hash.substr(1);
		// 添加路由跳转带参数，菜单栏无法获取焦点跟踪问题
		if (pathname.indexOf('?') != -1) {
			path = pathname.substring(0, pathname.indexOf('?'))
		} else {
			path = pathname;
		}
		// 获取当前所在的目录层级
		const rank = path.split('/');
		switch (rank.length) {
			case 2:  // 一级目录
				this.setState({
					selectedKeys: [path]
				})
				break;
			case 4: // 三级目录，要展开两个subMenu
				this.setState({
					selectedKeys: [path],
					openKeys: [rank.slice(0, 2).join('/'), rank.slice(0, 3).join('/')]
				})
				break;
			default:
				this.setState({
					selectedKeys: [path],
					openKeys: [path.substr(0, path.lastIndexOf('/'))]
				})
		}
	};

	// 选中时触发
	handleSelect() {
		// 匹配路由将保存到redux
		let path = window.location.hash.substr(1);
		let routerData = this.state.RouterData.concat(StaticRouterData);
		for (let i = 0; i < routerData.length; i++) {
			if (routerData[i].path === path) {
				store.dispatch({
					type: 'breadcrumArr',
					value: routerData[i]
				})
			}
			// 如果为/则默认给第一条数据
			if (path === '/') {
				store.dispatch({
					type: 'breadcrumArr',
					value: routerData[0]
				})
			}
		}
	};

	//此函数的作用只展开当前父级菜单（父级菜单下可能还有子菜单）
	onOpenChange = (openKeys) => {
		this.setState({
			openKeys
		})
		// if (openKeys.length === 0 || openKeys.length === 1) {
		// 	this.setState({
		// 		openKeys
		// 	})
		// 	return
		// }
		// //最新展开的菜单
		// const latestOpenKey = openKeys[openKeys.length - 1]
		// //判断最新展开的菜单是不是父级菜单，若是父级菜单就只展开一个，不是父级菜单就展开父级菜单和当前子菜单
		// //因为我的子菜单的key包含了父级菜单，所以不用像官网的例子单独定义父级菜单数组，然后比较当前菜单在不在父级菜单数组里面。
		// //只适用于3级菜单
		// if (latestOpenKey.includes(openKeys[0])) {
		// 	this.setState({
		// 		openKeys
		// 	})
		// } else {
		// 	this.setState({
		// 		openKeys: [latestOpenKey]
		// 	})
		// }
	};

	renderMenuItem = ({ path, icon, title, ENDesc, Paras }, item) => {
		let { defaultLanguage } = this.state;
		var pathNew = {
			pathname: path,
			state: Paras,
		}
		return (
			<Menu.Item key={path} menu_info={item}>
				<Link to={pathNew}>
					{icon && <Icon type={icon} />}
					<span>{defaultLanguage === 'EN' ? (ENDesc ? ENDesc : title) : title}</span>
				</Link>
			</Menu.Item>
		)
	};

	renderSubMenu = ({ path, icon, title, ENDesc, subs }) => {
		let { defaultLanguage } = this.state;
		return (
			<Menu.SubMenu
				children={subs}
				key={path}
				title={(
					<span>
						{icon && <Icon type={icon} />}<span>{defaultLanguage === 'EN' ? (ENDesc ? ENDesc : title) : title}</span>
					</span>
				)}
				style={{ maxHeight: '80vh', overflow: 'auto' }}
				className="scroll-bar-style"
			>
				{
					subs && subs.map(item => {
						return item.subs && item.subs.length > 0 ? this.renderSubMenu(item) : this.renderMenuItem(item, item)
					})
				}
			</Menu.SubMenu>
		)
	};

	// 将一级二级目录下相同的数据去重
	filterTwoArr(arr) {
		// console.log(arr)
		var arr2 = [];
		var obj = {};
		for (var i = 0; i < arr.length; i++) {
			if (arr[i].title !== obj.title && arr[i].subs) {
				obj = JSON.parse(JSON.stringify(arr[i]))
				arr2.push(obj);
			}
			if (arr[i].title !== obj.title) {
				obj = JSON.parse(JSON.stringify(arr[i]))
				arr2.push(obj);
			}
		}
		arr2.map((item, index) => {
			var result = [];
			var obj5 = {};
			if (item.subs) {
				for (var j = 0; j < item.subs.length; j++) {
					if (!obj5[item.subs[j].title]) {
						result.push(item.subs[j]);
						obj5[item.subs[j].title] = true;
					}
				}
				item.subs = result;
			}
			return result
		})
		return arr2;
	};

	// 根据查询处理菜单数据(存在问题，如果查询三级子表有重复的关键字则二级目录有重复，需要去重)
	filtrateMenuData(keyWord) {
		if (keyWord) {
			let listData = JSON.parse(JSON.stringify(this.state.MenusData))
			var reg = new RegExp(keyWord);
			var arr = [];
			for (let i in listData) {
				if (listData[i].subs) {
					let childs = JSON.parse((JSON.stringify(listData[i])));
					childs.subs = [];
					for (let j in listData[i].subs) {
						// 如果有三级子表的话
						if (listData[i].subs[j].subs) {
							let child2 = JSON.parse((JSON.stringify(listData[i].subs[j])));
							child2.subs = [];
							for (let k in listData[i].subs[j].subs) {
								if (reg.test(listData[i].subs[j].subs[k].title)) {
									child2.subs.push(listData[i].subs[j].subs[k])
									childs.subs.push(child2)
									arr.push(childs)
								}
							}
						} else {
							if (reg.test(listData[i].subs[j].title)) {
								childs.subs.push(listData[i].subs[j])
								arr.push(childs)
							}
						}
					}
				} else {
					if (reg.test(listData[i].title)) {
						arr.push(listData[i]);
					}
				}
			}
			if (arr.length >= 1) {
				// 将一级二级目录去重
				let filterData = JSON.parse(JSON.stringify(this.filterTwoArr(arr)))
				this.setState({ filterMenusData: filterData });
			} else {
				this.setState({ filterMenusData: [] }, () => {
					message.info("没有匹配的数据")
				});
			}

		} else {
			this.setState({ filterMenusData: this.state.MenusData });
		}
	};

	// 点击子跳转路由 --- 解决跳转取消选中错误
	handleOnClickMenu = (e) => {
		const menuInfo = e?.item?.props?.menu_info || {};
		console.log('menuInfo', e, menuInfo);
		this.setState({ selectedKeys: [e?.key || ''] }, () => {
			this.handleRecordClickThroughRate(menuInfo);
		})
	};

	// 获取子级菜单
	getSubMenuList = ({ title, ENDesc, icon, path, subs, ID }, index) => {
		let { defaultLanguage } = this.state;
		return (
			<SubMenu
				key={ID}
				title={(
					<span>
						{icon && <Icon type={icon} />}
						<span>{defaultLanguage === 'EN' ? (ENDesc ? ENDesc : title) : title}</span>
					</span>
				)}
			>
				{
					subs.map((item, subIndex) => {
						if (item.subs && item.subs.length) {
							return this.getSubMenuList(item, subIndex)
						}
						return (
							<Menu.Item key={item.ID} menu_info={item} onClick={this.openWindowBySubTab.bind(this, item)}>
								{item.icon && <Icon type={item.icon} />}
								<span>{defaultLanguage === 'EN' ? (item.ENDesc ? item.ENDesc : item.title) : item.title}</span>
							</Menu.Item>
						)
					})
				}
			</SubMenu>
		)
	};

	// 打开子窗口
	openWindowBySubTab = (item, event) => {
		this.props.addSubMenuTabData(item);
	};

	// 记录点击率
	handleRecordClickThroughRate = async (record) => {
		try {
			if (record?.ClickRateFlag !== 'Y') return;
			const patientData = React.$getSessionData('patientData')
			let data = {
				params: [{
					menuCode: record?.code || '',
					patID: patientData?.patID || '',
					admID: patientData?.admID || '',
				}]
			}
			let res = await React.$asyncPost(this, '01040293', data);
			console.log(res)
		} catch (error) {
			console.log(error);
		}
	};

	render() {
		const { openKeys, selectedKeys, defaultLanguage } = this.state;
		// 侧菜单
		let broadsideMenu = (
			<div className="menu-dom" style={{ height: document.body.clientHeight - 49 - 64 + 'px', overflowY: 'scroll' }}>
				<Menu
					style={{ background: '#28313a' }}
					className="broadside-menu"
					// defaultSelectedKeys={['1']}
					// defaultOpenKeys={['sub1']}
					openKeys={openKeys}
					onOpenChange={this.onOpenChange.bind(this)}
					selectedKeys={selectedKeys}
					onClick={(e) => this.handleOnClickMenu(e, 'broadside')}
					mode="inline"
					theme="dark"
				>
					{
						this.state.filterMenusData && this.state.filterMenusData.map((item, index) => {
							if (item.subs && item.subs.length) {
								return this.getSubMenuList(item, index)
							} else {
								return (
									<Menu.Item onClick={this.openWindowBySubTab.bind(this, item)} key={item.ID} menu_info={item}>
										{item.icon && <Icon type={item.icon} />}
										<span>{defaultLanguage === 'EN' ? (item.ENDesc ? item.ENDesc : item.title) : item.title}</span>
									</Menu.Item>
								)
							}
						})
					}
				</Menu>
			</div>
		)
		// 头菜单
		let headerMenu = (
			<div className="menu-header">
				<Menu
					onOpenChange={this.onOpenChange.bind(this)}
					mode="horizontal"
					theme="light"
					selectedKeys={selectedKeys}
					onClick={(e) => this.handleOnClickMenu(e, 'header')}
				// onSelect={this.handleSelect.bind(this)}
				>
					{
						this.state.filterMenusData && this.state.filterMenusData.map(item => {
							return item.subs && item.subs.length > 0 ? this.renderSubMenu(item) : this.renderMenuItem(item, item)
						})
					}
				</Menu>
			</div>
		)
		let loadMenu = this.props.flag === 'broadside' ? broadsideMenu : headerMenu
		return (
			<Spin tip="加载中..." spinning={this.state.showLoading}>
				<div className="system-menu">
					{loadMenu}
				</div>
			</Spin>
		)
	}
};

Menus.contextTypes = {
	router: PropTypes.object.isRequired
}  