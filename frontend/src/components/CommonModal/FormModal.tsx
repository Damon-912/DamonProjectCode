import React from 'react';
import { Modal, Button, Space } from 'antd';
import type { FormInstance } from 'antd';
import { modalSizes, ModalSize } from './modalSizes';

export interface FormModalProps {
  /** 弹框是否可见 */
  open: boolean;
  /** 弹框标题 */
  title: string;
  /** 表单实例 */
  form: FormInstance;
  /** 点击确定回调 */
  onOk: (values: any) => void;
  /** 点击取消回调 */
  onCancel: () => void;
  /** 确定按钮文字 */
  okText?: string;
  /** 取消按钮文字 */
  cancelText?: string;
  /** 是否显示加载状态 */
  loading?: boolean;
  /** 自定义宽度尺寸 */
  size?: ModalSize;
  /** 自定义底部内容 */
  footer?: React.ReactNode;
  /** 弹框内容 */
  children?: React.ReactNode;
  /** 表单内容样式 */
  formLayout?: 'horizontal' | 'vertical' | 'inline';
}

/**
 * FormModal - 表单弹框组件
 * 用于表单编辑、创建等场景
 */
export const FormModal: React.FC<FormModalProps> = ({
  open,
  title,
  form,
  onOk,
  onCancel,
  okText = '确定',
  cancelText = '取消',
  loading = false,
  size = 'md',
  footer,
  children,
  formLayout = 'vertical',
}) => {
  const sizeConfig = modalSizes[size];

  const handleOk = async () => {
    try {
      const values = await form.validateFields();
      onOk(values);
    } catch (error) {
      // 表单验证失败，不做处理
    }
  };

  return (
    <Modal
      open={open}
      title={title}
      onCancel={onCancel}
      width={sizeConfig.width}
      centered
      maskClosable={false}
      footer={
        footer || (
          <Space>
            <Button onClick={onCancel} disabled={loading}>
              {cancelText}
            </Button>
            <Button type="primary" onClick={handleOk} loading={loading}>
              {okText}
            </Button>
          </Space>
        )
      }
    >
      {React.isValidElement(children)
        ? React.cloneElement(children as React.ReactElement<any>, { form, layout: formLayout })
        : children}
    </Modal>
  );
};

export default FormModal;
