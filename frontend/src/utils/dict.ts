/**
 * dict.ts - DRG字典工具函数
 * 
 * 提供字典数据格式转换、查找等功能
 */
import type { DictItemOption } from '../api/basicData';

/**
 * 将字典项数组转换为 Select 组件 options 格式
 */
export function dictToOptions(items: DictItemOption[]): { value: string; label: string }[] {
  return items.map(item => ({
    value: item.code,
    label: item.name,
  }));
}

/**
 * 将字典项数组转换为 {code: name} 映射对象
 */
export function dictToMap(items: DictItemOption[]): Record<string, string> {
  return items.reduce((acc, item) => {
    acc[item.code] = item.name;
    return acc;
  }, {} as Record<string, string>);
}

/**
 * 从字典项数组中查找指定编码的选项
 */
export function findDictItem(items: DictItemOption[], code: string): DictItemOption | undefined {
  return items.find(item => item.code === code);
}

/**
 * 获取字典项显示名称
 */
export function getDictName(items: DictItemOption[], code: string, fallback: string = ''): string {
  const item = findDictItem(items, code);
  return item ? item.name : fallback || code;
}

/**
 * 根据值获取标签（用于表格渲染）
 */
export function getDictLabel(map: Record<string, string>, code: string, fallback: string = ''): string {
  return map[code] || fallback || code;
}
