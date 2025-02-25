/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Utils from '../utils/Utils';
import AxisBase from './AxisBase';
import { XAxisLabelPosition } from './XAxisLabelPosition';

/**
 * Class representing the x-axis labels settings. Only use the setter methods to
 * modify it. Do not access public variables directly. Be aware that not all
 * features the XLabels class provides are suitable for the RadarChart.
 *
 *
 */
export class XAxis extends AxisBase {
  /**
   * width of the x-axis labels in pixels - this is automatically
   * calculated by the computeSize() methods in the renderers
   */
  public mLabelWidth: number = 1;
  /**
   * height of the x-axis labels in pixels - this is automatically
   * calculated by the computeSize() methods in the renderers
   */
  public mLabelHeight: number = 1;
  /**
   * width of the (rotated) x-axis labels in pixels - this is automatically
   * calculated by the computeSize() methods in the renderers
   */
  public mLabelRotatedWidth: number = 1;
  /**
   * height of the (rotated) x-axis labels in pixels - this is automatically
   * calculated by the computeSize() methods in the renderers
   */
  public mLabelRotatedHeight: number = 1;
  /**
   * This is the angle for drawing the X axis labels (in degrees)
   */
  protected mLabelRotationAngle: number = 0;
  /**
   * if set to true, the chart will avoid that the first and last label entry
   * in the chart "clip" off the edge of the chart
   */
  private mAvoidFirstLastClipping: boolean = false;
  /**
   * the position of the x-labels relative to the chart
   */
  private mPosition: XAxisPosition = XAxisPosition.TOP;

  // private xCenterOffset:number = 0;

  // public longest:string='';

  /**
   * 表示标签在 X 轴上的偏移量
   */
  protected mLabelXOffset: number = 0;

  /**
   * 自定义x轴labels
   */
  private customLabels: number[] = [];

  /**
   * 使用自定义labels
   */
  private mUseCustomLabels: boolean = false;

  /**
   * 标签绘制位置
   */
  private xAxisLabelPosition: XAxisLabelPosition = XAxisLabelPosition.Center;

  constructor() {
    super();
    this.mYOffset = Utils.handleDataValues(4);
  }

  //
  // public getXCenterOffset(): number {
  //     return this.xCenterOffset;
  // }
  //
  // public setXCenterOffset(xCenterOffset: number): void {
  //     this.xCenterOffset = xCenterOffset;
  // }

  /**
   * returns the position of the x-labels
   */
  public getPosition(): XAxisPosition {
    return this.mPosition;
  }

  /**
   * sets the position of the x-labels
   *
   * @param pos
   */
  public setPosition(pos: XAxisPosition): void {
    this.mPosition = pos;
  }

  /**
   * returns the angle for drawing the X axis labels (in degrees)
   */
  public getLabelRotationAngle(): number {
    return this.mLabelRotationAngle;
  }

  /**
   * sets the angle for drawing the X axis labels (in degrees)
   *
   * @param angle the angle in degrees
   */
  public setLabelRotationAngle(angle: number): void {
    this.mLabelRotationAngle = angle;
  }

  /**
   * if set to true, the chart will avoid that the first and last label entry
   * in the chart "clip" off the edge of the chart or the screen
   *
   * @param enabled
   */
  public setAvoidFirstLastClipping(enabled: boolean): void {
    this.mAvoidFirstLastClipping = enabled;
  }

  /**
   * returns true if avoid-first-lastclipping is enabled, false if not
   *
   * @return
   */
  public isAvoidFirstLastClippingEnabled(): boolean {
    return this.mAvoidFirstLastClipping;
  }

  /**
   * 设置标签在 X 轴上的偏移量
   * @param xOffset - 偏移量
   */
  public setLabelXOffset(xOffset: number): void {
    this.mLabelXOffset = xOffset;
  }

  /**
   * 获取标签在 X 轴上的偏移量
   * @returns 偏移量
   */
  public getLabelXOffset(): number {
    return this.mLabelXOffset;
  }

  /**
   * 设置标签绘制位置
   * @param position - 绘制位置，可以是 LabelPosition.Left, LabelPosition.Center, LabelPosition.Right
   */
  public setXAxisLabelPosition(position: XAxisLabelPosition): void {
    this.xAxisLabelPosition = position;
  }

  /**
   * 获取标签绘制位置
   * @returns 绘制位置
   */
  public getXAxisLabelPosition(): XAxisLabelPosition {
    return this.xAxisLabelPosition;
  }

  /**
   *  设置自定义Labels
   * @param numbers labels数组
   */
  public setCustomLabels(numbers: number[]): void {
    this.customLabels = numbers;
  }

  /**
   * 获取自定义Labels
   * @returns labels数组
   */
  public getCustomLabels(): number[] {
    return this.customLabels;
  }

  /**
   * 设置是否使用自定义Labels
   * @param flag 是否使用自定义Labels
   */
  public setDrawCustomLabels(flag: boolean): void {
    this.mUseCustomLabels = flag;
  }

  /**
   * 检查是否正在使用自定义Labels
   * @returns 当前是否使用自定义Labels的布尔值
   */
  public isDrawCustomLabels(): boolean {
    return this.mUseCustomLabels;
  }

}

/**
 * enum for the position of the x-labels relative to the chart
 */
export enum XAxisPosition {
  TOP, BOTTOM, BOTH_SIDED, TOP_INSIDE, BOTTOM_INSIDE
}
