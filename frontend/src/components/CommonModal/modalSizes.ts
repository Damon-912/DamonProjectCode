/**
 * 弹框尺寸配置
 * 统一 Modal 弹框的尺寸规格
 */

export type ModalSize = 'sm' | 'md' | 'lg' | 'xl';

export interface ModalSizeConfig {
  width: string | number;
  height?: string;
}

/**
 * 弹框尺寸配置表
 * sm: 确认类、信息提示
 * md: 表单编辑（少字段）
 * lg: 表单编辑（多字段）
 * xl: 复杂表格、详情展示
 */
export const modalSizes: Record<ModalSize, ModalSizeConfig> = {
  sm: {
    width: 400,
  },
  md: {
    width: 600,
  },
  lg: {
    width: 900,
  },
  xl: {
    width: 1200,
  },
};

/**
 * 获取 Modal 的尺寸配置
 */
export const getModalSize = (size: ModalSize): ModalSizeConfig => {
  return modalSizes[size] || modalSizes.md;
};
