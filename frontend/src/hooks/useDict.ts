/**
 * useDict - DRG字典数据获取Hook
 * 
 * 用法：
 *   const { items, options, map, loading, refresh } = useDict('WARNING_LEVEL');
 *   // items:  原始字典项数组
 *   // options: Select组件可直接使用的{value,label}格式
 *   // map:    {key: label} 映射对象，用于表格渲染
 */
import { useState, useEffect, useCallback, useRef } from 'react';
import { getDictItemByTypeCode, type DictItemOption } from '../api/basicData';

interface UseDictResult {
  /** 原始字典项数组 */
  items: DictItemOption[];
  /** Select组件options格式 [{value: code, label: name}] */
  options: { value: string; label: string }[];
  /** {code: name} 映射对象 */
  map: Record<string, string>;
  /** 加载状态 */
  loading: boolean;
  /** 手动刷新 */
  refresh: () => void;
}

// 全局缓存，避免重复请求
const dictCache: Record<string, DictItemOption[]> = {};

/**
 * 根据字典类型编码获取字典项
 * @param typeCode 字典类型编码，如 'WARNING_LEVEL', 'WARNING_STATUS'
 * @param onlyEnabled 是否仅查询启用的项，默认true
 */
export function useDict(typeCode: string, onlyEnabled: boolean = true): UseDictResult {
  const [items, setItems] = useState<DictItemOption[]>([]);
  const [loading, setLoading] = useState(false);
  const mountedRef = useRef(true);

  const fetch = useCallback(async () => {
    if (!typeCode) {
      setItems([]);
      return;
    }

    // 优先使用缓存
    if (dictCache[typeCode]) {
      setItems(dictCache[typeCode]);
      return;
    }

    setLoading(true);
    try {
      const res = await getDictItemByTypeCode({
        typeCode,
        status: onlyEnabled ? 'Y' : '',
      });
      if (res.errorCode === '0' && res.result) {
        const rows = res.result.rows || [];
        dictCache[typeCode] = rows;
        if (mountedRef.current) {
          setItems(rows);
        }
      }
    } catch {
      // 静默处理错误
    } finally {
      if (mountedRef.current) {
        setLoading(false);
      }
    }
  }, [typeCode, onlyEnabled]);

  useEffect(() => {
    mountedRef.current = true;
    fetch();
    return () => {
      mountedRef.current = false;
    };
  }, [fetch]);

  // 转换为 Select options 格式
  const options = items.map(item => ({
    value: item.code,
    label: item.name,
  }));

  // 转换为 {code: name} 映射
  const map = items.reduce((acc, item) => {
    acc[item.code] = item.name;
    return acc;
  }, {} as Record<string, string>);

  return {
    items,
    options,
    map,
    loading,
    refresh: fetch,
  };
}

/**
 * 单个获取字典项名称（同步方式，需要字典已加载）
 * @param items 已加载的字典项数组
 * @param code 字典项编码
 */
export function getDictItemName(items: DictItemOption[], code: string): string {
  const item = items.find(i => i.code === code);
  return item ? item.name : code;
}

/**
 * 清除所有字典缓存
 */
export function clearDictCache(): void {
  Object.keys(dictCache).forEach(key => delete dictCache[key]);
}

export default useDict;
