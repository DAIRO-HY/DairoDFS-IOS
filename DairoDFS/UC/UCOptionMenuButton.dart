import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:dairo_dfs_app/extension/BuildContext++.dart';

///操作菜单按钮按钮
class UCOptionMenuButton extends StatelessWidget {
  ///点击回调事件
  final VoidCallback? onPressed;

  ///高度
  static const HEIGHT = 42.0;

  ///标题
  final String label;

  ///图标
  final IconData? icon;

  ///字体颜色
  final Color? color;

  ///是否禁用
  final bool disabled;

  const UCOptionMenuButton(
    this.label, {
    super.key,
    this.icon,
    this.onPressed,
    this.disabled = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.color.onSurface;
    return Expanded(
      child: Opacity(
          opacity: this.disabled ? .5 : 1,
          child: TextButton(
              style: TextButton.styleFrom(
                  minimumSize: const Size(0, 0), // 选填：设置最小尺寸
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 选填：紧凑的点击目标尺寸
                  padding: EdgeInsets.only(left: 8), //设置没有内边距
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0), // 设置圆角
                  )),
              onPressed: this.disabled ? null : this.onPressed,
              child: Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Column(children: [Icon(this.icon, size: 18, color: color), const Gap(8), context.textSmall(this.label, color: color)])))),
    );
  }
}
