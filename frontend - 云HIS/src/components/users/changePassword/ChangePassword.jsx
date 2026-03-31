import React from 'react';
import { Modal, Form, Input, message, } from 'antd';
import { forwardRef, useImperativeHandle, useState } from 'react';
import { encrypt } from '@tools/aes';

const ChangePassword = forwardRef((props, ref) => {
    const userData = React.$getUserData();
    let [isModalVisible, setIsModalVisible] = useState(false)
    let [form] = Form.useForm();

    //将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        setIsModalVisible,
        form,
    }));

    const handleOk = async () => {
        try {
            const values = await form.validateFields();
            values.originPassword = encrypt(values.originPassword); // 原密码
            values.password = encrypt(values.password); // 新密码
            values.confirmPassword = encrypt(values.confirmPassword); //确认密码
            let data = {
                params: [{
                    ...values,
                    power: 'password',
                    userID: userData?.userID || '',
                    updateUserID: userData?.userID || '',
                }]
            };
            const res = await React.$asyncPost('01040090', data);
            message.success(res?.errorMessage || '修改成功');
            setIsModalVisible(false);
            form.resetFields();
        } catch (error) {
            console.log(error);
        }
    };

    return (
        <Modal
            width="520px"
            title="重新设定密码"
            okText="确认修改"
            cancelText="取消"
            open={isModalVisible}
            onOk={handleOk}
            onCancel={() => { setIsModalVisible(false); form.resetFields() }}
        >
            <div style={{ margin: '24px 0' }}>
                <Form
                    name="basic"
                    autoComplete="off"
                    labelCol={{ span: 5 }}
                    wrapperCol={{ span: 18 }}
                    form={form}
                    initialValues={{ remember: true, username: userData?.userCode || undefined }}
                >
                    <Form.Item
                        label="用户账号" name="username">
                        <Input disabled value={userData?.userCode || undefined} />
                    </Form.Item>
                    <Form.Item
                        label="原密码"
                        name="originPassword"
                        rules={[
                            { required: true, message: '原始密码不能为空!' },
                        ]}
                    >
                        <Input.Password placeholder="请输入原始密码" />
                    </Form.Item>
                    <Form.Item
                        label="登录密码"
                        name="password"
                        rules={[{
                            required: true,
                            message: '请输入登录密码!'
                        }, {
                            pattern: /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[~!@#$%^&*()_+`\-={}:";'<>?,./]).{6,}$/,
                            message: '密码须包含特殊符号~!@#$%^&*()_+\-={}:;<>?,./及数字、大小写字母组成的至少6位！'
                        }]}
                    >
                        <Input.Password placeholder="数字、大小写字母和特殊符号组成的至少6位" />
                    </Form.Item>
                    <Form.Item
                        label="确认密码"
                        name="confirmPassword"
                        rules={[
                            { required: true, message: '请确认密码!' },
                            ({ getFieldValue }) => ({
                                validator(_, value) {
                                    if (!value || getFieldValue('password') === value) {
                                        return Promise.resolve();
                                    } else {
                                        return Promise.reject('两次密码不一致，请重新输入');
                                    }
                                },
                            }),
                        ]}
                    >
                        <Input.Password placeholder="请确认密码" />
                    </Form.Item>
                </Form>
            </div>
        </Modal>
    )
});

export default ChangePassword;