import { asyncPost } from '@tools/systemTools/https';
import { processingTableRequestData } from '@tools/systemTools/dataProcessing';
import { getLocalStorageData, setLocalStorageData } from '@tools/systemTools/other';
import { envConfig } from '@envConfig';
import store from '@store';

const getMenu = async (menuType = 2) => {
    try {
        let ROOT_APP_INFO = envConfig?.['ROOT_APP_INFO'] || 'drg-info';
        let appInfo = getLocalStorageData(ROOT_APP_INFO);
        let { userInfo } = appInfo;
        const { menuList } = store.getState();
        // 菜单数据缓存 - 避免不必要的重复获取，正常用户菜单不会经常发生变化【如需再获取，F5刷新界面】。
        let nMenuList = menuList && Array.isArray(menuList) && menuList.length > 0 ? [...menuList] : [];
        if (!(nMenuList && nMenuList.length > 0)) {
            let data = {
                params: [{
                    // 菜单类型
                    type: menuType,
                    // 角色ID
                    groupID: userInfo?.groupID || '',
                    // 科室id
                    locID: userInfo?.locID || ''
                }]
            };
            const res = await asyncPost('3001', data);
            nMenuList = processingTableRequestData(res);
            appInfo.menuList = nMenuList;
            store.dispatch({
                type: 'menuList',
                data: nMenuList
            });
            setLocalStorageData(ROOT_APP_INFO, appInfo);
        }
        return nMenuList;
    } catch (error) {
        console.log(error);
        return [];
    }
};

export default getMenu;