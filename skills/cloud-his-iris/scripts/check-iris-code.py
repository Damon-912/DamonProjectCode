#!/usr/bin/env python3
"""
IRIS代码规范检查脚本
用于检查InterSystems IRIS/Cache ObjectScript代码是否符合普瑞云HIS开发规范
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Dict, Tuple, Optional


class IRISCodeChecker:
    """IRIS代码规范检查器"""

    def __init__(self, base_dir: str):
        self.base_dir = Path(base_dir)
        self.errors = []
        self.warnings = []

        # 业务包列表
        self.business_packages = [
            'Decoct', 'Pharmacy', 'Inventory', 'Inpatient',
            'Outpatient', 'Emergency', 'MedicalRecord', 'Registration',
            'Billing', 'Insurance', 'Laboratory', 'Radiology',
            'BloodTransfusion', 'Nutrition', 'Nursing', 'Surgery', 'Admin'
        ]

        # CB表必填字段
        self.cb_required_fields = [
            'Code', 'Descripts', 'ENDescripts',
            'StartDate', 'StopDate',
            'CreateDate', 'CreateUserDr'
        ]

def check_file(self, file_path: Path) -> None:
    """检查单个文件"""
    print(f"正在检查文件: {file_path}")
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        # 判断文件类型
        class_name, package = self.extract_class_info(content)
        print(f"  类名: {class_name}, 包: {package}")
        if not class_name:
            print(f"  跳过: 未找到类定义")
            return

        # 检查规范
        if package and package == 'User':
            print(f"  检查表类规范...")
            self.check_table_class(content, file_path)
        elif package and any(bp in package for bp in self.business_packages):
            print(f"  检查业务类规范...")
            self.check_business_class(content, file_path)
        else:
            print(f"  跳过: 未识别的包类型")

    except Exception as e:
        print(f"  错误: {e}")
        self.warnings.append(f"{file_path}: 无法读取文件 - {e}")

    def extract_class_info(self, content: str) -> Tuple[Optional[str], Optional[str]]:
        """提取类名和包名"""
        match = re.search(r'Class\s+(\w+)\.(\w+)', content)
        if match:
            return match.group(2), match.group(1)
        return None, None

    def check_table_class(self, content: str, file_path: Path) -> None:
        """检查表类规范"""

        # 1. 检查是否在User包下
        if not re.search(r'Class\s+User\.\w+', content):
            self.errors.append(f"{file_path}: 表类必须保存到User包下")

        # 2. 检查表名前缀
        class_name_match = re.search(r'Class\s+User\.(CB\w+|HB\w+|BS\w+)', content)
        if not class_name_match:
            self.warnings.append(f"{file_path}: 表名应使用CB/HB/BS前缀")
        else:
            table_prefix = class_name_match.group(1)[:2]

            # 3. CB表必填字段检查
            if table_prefix == 'CB':
                missing_fields = []
                for field in self.cb_required_fields:
                    if not re.search(rf'Property\s+{field}', content):
                        missing_fields.append(field)

                if missing_fields:
                    self.errors.append(
                        f"{file_path}: CB表缺少必填字段: {', '.join(missing_fields)}"
                    )

    def check_business_class(self, content: str, file_path: Path) -> None:
        """检查业务类规范"""

        # 1. 检查是否使用正确的包名
        has_valid_package = False
        for bp in self.business_packages:
            if f'src.{bp}.' in content or f'class src.{bp}.' in content.lower():
                has_valid_package = True
                break

        if not has_valid_package:
            self.warnings.append(f"{file_path}: 业务类应使用标准业务包")

        # 2. 检查方法注释
        methods = re.findall(r'ClassMethod\s+(\w+)\s*\(', content)
        for method in methods:
            # 检查方法上方是否有注释
            method_pattern = rf'ClassMethod\s+{method}\s*\('
            match = re.search(method_pattern, content)
            if match:
                # 获取方法位置前的内容
                pre_content = content[:match.start()]
                # 检查最后3行是否有注释
                lines_before = pre_content.split('\n')[-3:]
                has_comment = any('///' in line for line in lines_before)
                if not has_comment:
                    self.warnings.append(f"{file_path}: 方法 '{method}' 缺少注释")

        # 3. 检查try-catch使用
        for method in methods:
            method_pattern = rf'ClassMethod\s+{method}\s*\([^)]*\)\s+As\s+\w+.*?{{(.*?)}}'
            method_match = re.search(method_pattern, content, re.DOTALL)
            if method_match:
                method_body = method_match.group(1)
                # 检查是否包含数据操作
                if re.search(r'operatetable\.(Insert|Update|Delete|GetRow)', method_body):
                    if 'Try' not in method_body or 'Catch' not in method_body:
                        self.errors.append(
                            f"{file_path}: 方法 '{method}' 包含数据操作但未使用try-catch"
                        )

        # 4. 检查调试语句
        if re.search(r'^\s*["\']\s*w\s+', content, re.MULTILINE):
            self.errors.append(f"{file_path}: 代码中包含调试语句（w \"xxx\"），请删除")

        if re.search(r'\bWRITE\s+', content, re.IGNORECASE):
            self.errors.append(f"{file_path}: 代码中包含调试语句（WRITE），请删除")

        # 5. 检查事务处理
        for method in methods:
            method_pattern = rf'ClassMethod\s+{method}\s*\([^)]*\)\s+As\s+\w+.*?{{(.*?)}}'
            method_match = re.search(method_pattern, content, re.DOTALL)
            if method_match:
                method_body = method_match.group(1)

                # 检查TSTART和TCOMMIT
                has_tstart = re.search(r'\bTSTART\b', method_body)
                has_tcommit = re.search(r'\bTCOMMIT\b', method_body)
                has_trollback = re.search(r'\bTROLLBACK\b', method_body)

                if has_tstart:
                    if not has_tcommit:
                        self.errors.append(
                            f"{file_path}: 方法 '{method}' 使用了TSTART但缺少TCOMMIT"
                        )
                    if not has_trollback:
                        self.warnings.append(
                            f"{file_path}: 方法 '{method}' 使用了TSTART但缺少TROLLBACK"
                        )

                if has_tcommit and not has_tstart:
                    self.errors.append(
                        f"{file_path}: 方法 '{method}' 使用了TCOMMIT但缺少TSTART"
                    )

                if has_trollback and not has_tstart:
                    self.errors.append(
                        f"{file_path}: 方法 '{method}' 使用了TROLLBACK但缺少TSTART"
                    )

        # 6. 检查Query定义
        queries = re.findall(r'Query\s+(\w+)\s*\([^)]*\)\s+As\s+%Query\(ROWSPEC\s*=\s*"[^"]+"\)', content)
        for query in queries:
            # 检查Execute方法
            if not re.search(rf'ClassMethod\s+{query}Execute\(', content):
                self.errors.append(f"{file_path}: Query '{query}' 缺少Execute方法")

            # 检查Fetch方法
            if not re.search(rf'ClassMethod\s+{query}Fetch\(', content):
                self.errors.append(f"{file_path}: Query '{query}' 缺少Fetch方法")

            # 检查Close方法
            if not re.search(rf'ClassMethod\s+{query}Close\(', content):
                self.errors.append(f"{file_path}: Query '{query}' 缺少Close方法")

        # 7. 检查禁止使用SQL语句提取数据
        sql_patterns = [
            r'&sql\s*\(',                           # &sql() 嵌入式SQL
            r'##class\s*\(\s*%SQL\.Statement\s*\)',  # %SQL.Statement
            r'##class\s*\(\s*%ResultSet\s*\)',       # %ResultSet
            r'\.%Prepare\s*\(',                      # %Prepare 方法调用
            r'\.%Execute\s*\(',                      # %Execute 方法调用（SQL上下文）
        ]
        for pattern in sql_patterns:
            if re.search(pattern, content, re.IGNORECASE):
                self.errors.append(
                    f"{file_path}: 禁止使用SQL语句提取数据，只能通过Global提取数据"
                )
                break

        # 8. 检查SQL注入风险
        # 检查字符串拼接SQL
        sql_concat_patterns = [
            r'Set\s+tSQL\s*=\s*[^;]*?\.\s*\w+',  # 字符串拼接
            r'Prepare\([^)]*\+\s*\w+',  # Prepare中使用拼接
        ]
        for pattern in sql_concat_patterns:
            if re.search(pattern, content):
                self.errors.append(
                    f"{file_path}: 检测到可能的SQL注入风险（字符串拼接SQL）"
                )
                break

        # 9. 检查外键命名
        # 检查是否以Dr结尾的外键字段
        property_matches = re.findall(r'Property\s+(\w+)\s+As\s+([A-Z]\w+\.[A-Z]\w+)', content)
        for prop_name, prop_type in property_matches:
            # 如果是外键（引用其他类），检查是否以Dr结尾
            if '.' in prop_type:
                if not prop_name.endswith('Dr'):
                    self.warnings.append(
                        f"{file_path}: 外键字段 '{prop_name}' 应以Dr结尾"
                    )

    def check_directory(self, directory: Path) -> None:
        """递归检查目录"""
        if not directory.exists():
            print(f"目录不存在: {directory}")
            return

        for file_path in directory.rglob('*.cls'):
            if file_path.is_file():
                self.check_file(file_path)

    def print_results(self) -> None:
        """打印检查结果"""
        print("=" * 80)
        print("IRIS代码规范检查结果")
        print("=" * 80)

        if not self.errors and not self.warnings:
            print("\n✅ 所有检查通过！代码符合规范。\n")
            return

        # 打印错误
        if self.errors:
            print(f"\n❌ 发现 {len(self.errors)} 个错误:\n")
            for i, error in enumerate(self.errors, 1):
                print(f"  [{i}] {error}")

        # 打印警告
        if self.warnings:
            print(f"\n⚠️  发现 {len(self.warnings)} 个警告:\n")
            for i, warning in enumerate(self.warnings, 1):
                print(f"  [{i}] {warning}")

        # 打印统计
        print("\n" + "=" * 80)
        print(f"统计: {len(self.errors)} 个错误, {len(self.warnings)} 个警告")
        print("=" * 80)

    def has_errors(self) -> bool:
        """是否有错误"""
        return len(self.errors) > 0


def main():
    """主函数"""
    print("脚本启动...")
    # 获取项目根目录
    script_dir = Path(__file__).parent
    print(f"脚本目录: {script_dir}")
    skill_dir = script_dir.parent
    project_dir = skill_dir.parent
    default_src_dir = project_dir / "src"

    # 解析命令行参数
    import argparse
    parser = argparse.ArgumentParser(description='IRIS代码规范检查脚本')
    parser.add_argument('path', nargs='?', default=str(default_src_dir),
                        help='要检查的文件或目录路径（默认：src目录）')
    args = parser.parse_args()

    target_path = Path(args.path)
    print(f"目标路径: {target_path}")
    print(f"路径存在: {target_path.exists()}")
    print(f"是文件: {target_path.is_file()}")
    print(f"是目录: {target_path.is_dir()}")

    if not target_path.exists():
        print(f"错误: 路径不存在: {target_path}")
        sys.exit(1)

    print()
    print("=" * 80)
    print("IRIS代码规范检查")
    print("=" * 80)
    print()

    # 创建检查器
    checker = IRISCodeChecker(str(target_path.parent))

    # 检查代码
    if target_path.is_file():
        checker.check_file(target_path)
    elif target_path.is_dir():
        checker.check_directory(target_path)

    # 打印结果
    print()
    checker.print_results()

    # 返回退出码
    sys.exit(1 if checker.has_errors() else 0)


if __name__ == "__main__":
    main()
