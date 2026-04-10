import React from 'react';
import { Modal } from 'antd';
import { modalSizes, ModalSize } from './modalSizes';

export interface ConfirmModalProps {
  /** 弹框是否可见 */
  open: boolean;
  /** 弹框标题 */
  title: string;
  /** 弹框内容 */
  content: React.ReactNode;
  /** 确定按钮文字 */
  okText?: string;
  /** 取消按钮文字 */
  cancelText?: string;
  /** 点击确定回调 */
  onOk?: () => void;
  /** 点击取消回调 */
  onCancel?: () => void;
  /** 是否显示删除按钮样式 */
  danger?: boolean;
  /** 自定义宽度尺寸 */
  size?: ModalSize;
  /** 是否显示加载状态 */
  loading?: boolean;
}

/**
 * ConfirmModal - 确认对话框组件
 * 用于需要用户确认的操作，如删除、取消等
 */
export const ConfirmModal: React.FC<ConfirmModalProps> = ({
  open,
  title,
  content,
  okText = '确定',
  cancelText = '取消',
  onOk,
  onCancel,
  danger = false,
  size = 'sm',
  loading = false,
}) => {
  const sizeConfig = modalSizes[size];

  return (
    <Modal
      open={open}
      title={title}
      onOk={onOk}
      onCancel={onCancel}
      okText={okText}
      cancelText={cancelText}
      okButtonProps={{ danger, loading }}
      width={sizeConfig.width}
      centered
      maskClosable={false}
    >
      {content}
    </Modal>
  );
};

export default ConfirmModal;
