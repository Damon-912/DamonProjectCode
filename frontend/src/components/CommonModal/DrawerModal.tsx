import React from 'react';
import { Drawer, Button, Space, Form } from 'antd';
import type { FormInstance } from 'antd';

export interface DrawerModalProps {
  /** 抽屉是否可见 */
  open: boolean;
  /** 抽屉标题 */
  title: string;
  /** 抽屉宽度 */
  width?: number | string;
  /** 表单实例 */
  form?: FormInstance;
  /** 点击确定回调 */
  onOk?: (values: any) => void;
  /** 点击取消回调 */
  onClose: () => void;
  /** 确定按钮文字 */
  okText?: string;
  /** 取消按钮文字 */
  cancelText?: string;
  /** 是否显示加载状态 */
  loading?: boolean;
  /** 是否显示底部按钮 */
  showFooter?: boolean;
  /** 抽屉位置 */
  placement?: 'left' | 'right' | 'top' | 'bottom';
  /** 抽屉内容 */
  children?: React.ReactNode;
}

/**
 * DrawerModal - 抽屉弹框组件
 * 用于侧边滑出的表单编辑、数据展示等场景
 */
export const DrawerModal: React.FC<DrawerModalProps> = ({
  open,
  title,
  width = 600,
  form,
  onOk,
  onClose,
  okText = '确定',
  cancelText = '取消',
  loading = false,
  showFooter = true,
  placement = 'right',
  children,
}) => {
  const handleOk = async () => {
    if (!form || !onOk) return;
    try {
      const values = await form.validateFields();
      onOk(values);
    } catch (error) {
      // 表单验证失败，不做处理
    }
  };

  return (
    <Drawer
      open={open}
      title={title}
      width={width}
      onClose={onClose}
      placement={placement}
      maskClosable={false}
      footer={
        showFooter ? (
          <Space style={{ width: '100%', justifyContent: 'flex-end' }}>
            <Button onClick={onClose} disabled={loading}>
              {cancelText}
            </Button>
            <Button type="primary" onClick={handleOk} loading={loading}>
              {okText}
            </Button>
          </Space>
        ) : null
      }
    >
      {React.isValidElement(children)
        ? React.cloneElement(children as React.ReactElement<any>, { form })
        : children}
    </Drawer>
  );
};

export default DrawerModal;
