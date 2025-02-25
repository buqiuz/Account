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

import ChartAnimator from '../animation/ChartAnimator';
import PieChart from '../charts/PieChartModel';
import ChartPixelMap from '../data/ChartPixelMap';
import EntryOhos from '../data/EntryOhos';
import Paint, { Style, TextPaint } from '../data/Paint';
import PieData from '../data/PieData';
import { ValuePosition } from '../data/PieDataSet';
import PieEntry from '../data/PieEntry';
import MyRect from '../data/Rect';
import IValueFormatter from '../formatter/IValueFormatter';
import Highlight from '../highlight/Highlight';
import IPieDataSet from '../interfaces/datasets/IPieDataSet';
import ColorTemplate from '../utils/ColorTemplate';
import { JArrayList } from '../utils/JArrayList';
import MPPointF from '../utils/MPPointF';
import MyMath from '../utils/MyMath';
import Utils from '../utils/Utils';
import ViewPortHandler from '../utils/ViewPortHandler';
import DataRenderer from './DataRenderer';
import HashMap from '@ohos.util.HashMap';
import CanvasUtil from '../utils/CanvasUtil';

export default class PieChartRenderer extends DataRenderer {
  protected mChart: PieChart;
  /**
   * paint for the hole in the center of the pie chart and the transparent
   * circle
   */
  protected mHolePaint: Paint;
  protected mTransparentCirclePaint: Paint;
  protected mValueLinePaint: Paint;
  /**
   * paint object for the text that can be displayed in the center of the
   * chart
   */
  private mCenterTextPaint: TextPaint;
  /**
   * paint object used for drwing the slice-text
   */
  private mEntryLabelsPaint: Paint;
  private mCenterTextLayout: string = "";
  /*StaticLayout*/
  private mCenterTextLastValue: string = "";
  /*CharSequence*/
  private mCenterTextLastBounds: MyRect = new MyRect();
  private mRectBuffer: Array<MyRect> = [new MyRect(), new MyRect(), new MyRect()];
  /**
   * Bitmap for drawing the center hole
   */
  protected mDrawBitmap: Map<object, PixelMap> | null = null;
  protected mBitmapCanvas: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  textSizeCache = new HashMap<string, TextMetrics>();

  constructor(chart: PieChart, animator: ChartAnimator,
              viewPortHandler: ViewPortHandler) {
    super(animator, viewPortHandler);
    this.mChart = chart;
    this.mHolePaint = new Paint();
    this.mHolePaint.setColor(Color.White);
    this.mHolePaint.setStyle(Style.FILL);
    this.mTransparentCirclePaint = new Paint();
    this.mTransparentCirclePaint.setColor(Color.White);
    this.mTransparentCirclePaint.setStyle(Style.FILL);
    this.mTransparentCirclePaint.setGlobalAlpha(105/255);
    this.mCenterTextPaint = new TextPaint();
    this.mCenterTextPaint.setColor(Color.Black);
    this.mCenterTextPaint.setTextSize(Utils.handleDataValues(12));

    this.mValuePaint.setTextSize(Utils.handleDataValues(13));
    this.mValuePaint.setColor(Color.White);
    this.mValuePaint.setTextAlign('center');
    this.mEntryLabelsPaint = new Paint();
    this.mEntryLabelsPaint.setColor(Color.White);
    this.mEntryLabelsPaint.setTextAlign('center');
    this.mEntryLabelsPaint.setTextSize(Utils.handleDataValues(13));
    this.mValueLinePaint = new Paint();
    this.mValueLinePaint.setStyle(Style.STROKE);
  }

  public getPaintHole() {
    return this.mHolePaint;
  }

  public getPaintTransparentCircle(): Paint {
    return this.mTransparentCirclePaint;
  }

  public getPaintCenterText(): TextPaint {
    return this.mCenterTextPaint;
  }

  public getPaintEntryLabels(): Paint {
    return this.mEntryLabelsPaint;
  }

  // @Override
  public initBuffers(): void {
  }

  // @Override
  public drawData(c: CanvasRenderingContext2D): void {
    CanvasUtil.clearCanvas(c);

    let pieData: PieData | null = this.mChart.getData();

    if (pieData) {
      let dataSets = pieData.getDataSets();
      for (let i = 0; i < dataSets.size(); i++) {
        let set = dataSets.get(i);
        if (set.isVisible() && set.getEntryCount() > 0)
          this.drawDataSet(c, set);
      }
    }
  }

  private mPathBuffer: Path2D = new Path2D();
  private mInnerRectBuffer: MyRect = new MyRect();

  protected calculateMinimumRadiusForSpacedSlice(
    center: MPPointF,
    radius: number,
    angle: number,
    arcStartPointX: number,
    arcStartPointY: number,
    startAngle: number,
    sweepAngle: number): number {
    let angleMiddle: number = startAngle + sweepAngle / 2.0;

    // Other point of the arc
    let arcEndPointX: number = center.x + radius * /*(float)*/
    Math.cos((startAngle + sweepAngle) * Utils.FDEG2RAD);
    let arcEndPointY: number = center.y + radius * /*(float)*/
    Math.sin((startAngle + sweepAngle) * Utils.FDEG2RAD);

    // Middle point on the arc
    let arcMidPointX: number = center.x + radius * /*(float)*/
    Math.cos(angleMiddle * Utils.FDEG2RAD);
    let arcMidPointY: number = center.y + radius * /*(float)*/
    Math.sin(angleMiddle * Utils.FDEG2RAD);

    // This is the base of the contained triangle
    let basePointsDistance: number = Math.sqrt(
      Math.pow(arcEndPointX - arcStartPointX, 2) +
      Math.pow(arcEndPointY - arcStartPointY, 2));

    // After reducing space from both sides of the "slice",
    //   the angle of the contained triangle should stay the same.
    // So let's find out the height of that triangle.
    let containedTriangleHeight: number = /*(float)*/
      (basePointsDistance / 2.0 *
      Math.tan((180.0 - angle) / 2.0 * Utils.DEG2RAD));

    // Now we subtract that from the radius
    let spacedRadius: number = radius - containedTriangleHeight;

    // And now subtract the height of the arc that's between the triangle and the outer circle
    spacedRadius -= Math.sqrt(
      Math.pow(arcMidPointX - (arcEndPointX + arcStartPointX) / 2.0, 2) +
      Math.pow(arcMidPointY - (arcEndPointY + arcStartPointY) / 2.0, 2));

    return spacedRadius;
  }

  /**
   * Calculates the sliceSpace to use based on visible values and their size compared to the set sliceSpace.
   *
   * @param dataSet
   * @return
   */
  protected getSliceSpace(dataSet: IPieDataSet): number {

    let chartData = this.mChart.getData();

    if (!chartData || !this.mViewPortHandler) {
      return -1;
    }

    if (!dataSet.isAutomaticallyDisableSliceSpacingEnabled())
      return dataSet.getSliceSpace();

    let spaceSizeRatio: number = dataSet.getSliceSpace() / this.mViewPortHandler.getSmallestContentExtension();
    let minValueRatio: number = dataSet.getYMin() / chartData.getYValueSum() * 2;

    let sliceSpace: number = spaceSizeRatio > minValueRatio ? 0 : dataSet.getSliceSpace();

    return sliceSpace;
  }

  protected drawDataSet(c: CanvasRenderingContext2D, dataSet: IPieDataSet): void {

    if (!this.mAnimator) {
      return;
    }

    let angle: number = 0; // 当前绘制的扇形起始角度
    let rotationAngle: number = this.mChart.getRotationAngle(); // 饼图旋转的角度

    let phaseX: number = this.mAnimator.getPhaseX(); // X轴动画阶段
    let phaseY: number = this.mAnimator.getPhaseY(); // Y轴动画阶段

    let circleBox: MyRect = this.mChart.getCircleBox(); // 饼图边框

    let entryCount: number = dataSet.getEntryCount(); // 数据集中的数据点数量
    let drawAngles: number[] = this.mChart.getDrawAngles(); // 饼图每个扇形的绘制角度
    let center: MPPointF = this.mChart.getCenterCircleBox(); // 饼图中心点坐标
    let radius: number = this.mChart.getRadius(); // 饼图半径
    let drawInnerArc: boolean = this.mChart.isDrawHoleEnabled() && !this.mChart.isDrawSlicesUnderHoleEnabled(); // 是否绘制内圆环
    let userInnerRadius: number = drawInnerArc
      ? radius * (this.mChart.getHoleRadius() / 100.0)
      : 0.0; // 用户指定的内圆环半径
    let roundedRadius: number = (radius - (radius * this.mChart.getHoleRadius() / 100)) / 2; // 圆角扇形的圆角半径
    let roundedCircleBox: MyRect = new MyRect(); // 圆角扇形的边框
    let drawRoundedSlices: boolean = drawInnerArc && this.mChart.isDrawRoundedSlicesEnabled(); // 是否绘制圆角扇形

    let visibleAngleCount: number = 0; //可见的扇形数量
    for (let j: number = 0; j < entryCount; j++) {
      // draw only if the value is greater than zero 仅在数值大于零时绘制
      if ((Math.abs(dataSet.getEntryForIndex(j).getY()) > Utils.FLOAT_EPSILON)) {
        visibleAngleCount++;
      }
    }

    let sliceSpace: number = visibleAngleCount <= 1 ? 0.0 : this.getSliceSpace(dataSet); // 扇形之间的间隔

    for (let j: number = 0; j < entryCount; j++) {

      let sliceAngle: number = drawAngles[j]; // 当前扇形的绘制角度
      let innerRadius: number = userInnerRadius; // 内圆环半径

      let e: EntryOhos = dataSet.getEntryForIndex(j); // 数据集中的数据点

      // draw only if the value is greater than zero (仅在数值大于零时绘制)
      if (!(Math.abs(e.getY()) > Utils.FLOAT_EPSILON)) {
        angle += sliceAngle * phaseX;
        continue;
      }

      // Don't draw if it's highlighted, unless the chart uses rounded slices (如果启用了高亮且图表需要高亮当前扇形，并且不绘制圆角扇形，则不进行绘制)
      if (dataSet.isHighlightEnabled() && this.mChart.needsHighlight(j) && !drawRoundedSlices) {
        angle += sliceAngle * phaseX;
        continue;
      }

      // 是否考虑扇形间的间隔
      const accountForSliceSpacing: boolean = sliceSpace > 0.0 && sliceAngle <= 180.0;

      this.mRenderPaint.setColor(dataSet.getColor(j)); // 设置画笔颜色

      // 计算外部扇形的起始角度和扫过的角度
      const sliceSpaceAngleOuter: number = visibleAngleCount == 1 ?
        0.0 :
        sliceSpace / (Utils.FDEG2RAD * radius);
      const startAngleOuter: number = rotationAngle + (angle + sliceSpaceAngleOuter / 2.0) * phaseY;
      let sweepAngleOuter: number = (sliceAngle - sliceSpaceAngleOuter) * phaseY;
      if (sweepAngleOuter < 0.0) {
        sweepAngleOuter = 0.0;
      }

      // this.mPathBuffer.reset(); //重置路径
      this.mPathBuffer = new Path2D()

      if (drawRoundedSlices) {
        let x: number = center.x + (radius - roundedRadius) * /*(float)*/
        Math.cos(startAngleOuter * Utils.FDEG2RAD);
        let y: number = center.y + (radius - roundedRadius) * /*(float)*/
        Math.sin(startAngleOuter * Utils.FDEG2RAD);
        roundedCircleBox.set(x - roundedRadius, y - roundedRadius, x + roundedRadius, y + roundedRadius);
      }

      let arcStartPointX: number = center.x + radius * /*(float)*/
      Math.cos(startAngleOuter * Utils.FDEG2RAD);
      let arcStartPointY: number = center.y + radius * /*(float)*/
      Math.sin(startAngleOuter * Utils.FDEG2RAD);

      if (sweepAngleOuter >= 360.0 && sweepAngleOuter % 360 <= Utils.FLOAT_EPSILON) {
        // ohos is doing "mod 360"
        this.mPathBuffer.arc(center.x, center.y, radius, 0, 2 * Math.PI)
        // this.mPathBuffer.addCircle(center.x, center.y, radius, Path.Direction.CW);
      } else {
        // 绘制圆角扇形的路径
        if (drawRoundedSlices) {
          this.arcTo(this.mPathBuffer, roundedCircleBox, startAngleOuter + 180, -180);
        }
        // 绘制普通扇形的路径
        this.arcTo(this.mPathBuffer, circleBox, startAngleOuter, sweepAngleOuter);
      }

      // API < 21 does not receive floats in addArc, but a RectF
      this.mInnerRectBuffer.set(
        center.x - innerRadius,
        center.y - innerRadius,
        center.x + innerRadius,
        center.y + innerRadius);

      if (drawInnerArc && (innerRadius > 0.0 || accountForSliceSpacing)) {

        if (accountForSliceSpacing) {
          let minSpacedRadius: number =
          this.calculateMinimumRadiusForSpacedSlice(
            center, radius,
            sliceAngle * phaseY,
            arcStartPointX, arcStartPointY,
            startAngleOuter,
            sweepAngleOuter);

          if (minSpacedRadius < 0.0)
            minSpacedRadius = -minSpacedRadius;

          innerRadius = Math.max(innerRadius, minSpacedRadius);
        }

        let sliceSpaceAngleInner: number = visibleAngleCount == 1 || innerRadius == 0.0 ?
          0.0 :
          sliceSpace / (Utils.FDEG2RAD * innerRadius);
        let startAngleInner: number = rotationAngle + (angle + sliceSpaceAngleInner / 2.0) * phaseY;
        let sweepAngleInner: number = (sliceAngle - sliceSpaceAngleInner) * phaseY;
        if (sweepAngleInner < 0.0) {
          sweepAngleInner = 0.0;
        }
        let endAngleInner: number = startAngleInner + sweepAngleInner;

        if (sweepAngleOuter >= 360.0 && sweepAngleOuter % 360 <= Utils.FLOAT_EPSILON) {
          // ohos is doing "mod 360"
          this.mPathBuffer.arc(center.x, center.y, innerRadius, 0, 2 * Math.PI, true);
        } else {

          if (drawRoundedSlices) {
            let x: number = center.x + (radius - roundedRadius) * /*(float)*/
            Math.cos(endAngleInner * Utils.FDEG2RAD);
            let y: number = center.y + (radius - roundedRadius) * /*(float) */
            Math.sin(endAngleInner * Utils.FDEG2RAD);
            roundedCircleBox.set(x - roundedRadius, y - roundedRadius, x + roundedRadius, y + roundedRadius);
            // this.mPathBuffer.arcTo(roundedCircleBox.left, roundedCircleBox.top,roundedCircleBox.right,roundedCircleBox.bottom,endAngleInner/*, 180*/);
            this.arcTo(this.mPathBuffer, roundedCircleBox, endAngleInner, 180);
          } else
            this.mPathBuffer.lineTo(
              center.x + innerRadius * /*(float)*/
              Math.cos(endAngleInner * Utils.FDEG2RAD),
              center.y + innerRadius * /*(float)*/
              Math.sin(endAngleInner * Utils.FDEG2RAD));
          /*mPathBuffer.arcTo(
            mInnerRectBuffer,
            endAngleInner,
            -sweepAngleInner
          );*/
          this.arcTo(this.mPathBuffer,
            this.mInnerRectBuffer,
            endAngleInner,
            -sweepAngleInner);
        }
      } else {

        if (sweepAngleOuter % 360 > Utils.FLOAT_EPSILON) {
          if (accountForSliceSpacing) {

            // 计算扇形中心的角度
            let angleMiddle: number = startAngleOuter + sweepAngleOuter / 2.0;

            // 计算间隔偏移
            let sliceSpaceOffset: number =
            this.calculateMinimumRadiusForSpacedSlice(
              center,
              radius,
              sliceAngle * phaseY,
              arcStartPointX,
              arcStartPointY,
              startAngleOuter,
              sweepAngleOuter);

            let arcEndPointX: number = center.x +
            sliceSpaceOffset * /*(float)*/
            Math.cos(angleMiddle * Utils.FDEG2RAD);
            let arcEndPointY: number = center.y +
            sliceSpaceOffset * /*(float)*/
            Math.sin(angleMiddle * Utils.FDEG2RAD);

            this.mPathBuffer.lineTo(
              arcEndPointX,
              arcEndPointY);

          } else {
            this.mPathBuffer.lineTo(
              center.x,
              center.y);
          }
        }

      }

      this.mPathBuffer.closePath(); // 封闭路径
      // this.mBitmapCanvas.drawPath(mPathBuffer, mRenderPaint);

      // 绘制路径
      Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
      // c.stroke(this.mPathBuffer);
      c.fill(this.mPathBuffer);

      angle += sliceAngle * phaseX; // 更新角度
    }

    MPPointF.recycleInstance(center); // 释放中心点实例
  }

  // @Override
  public drawValues(c: CanvasRenderingContext2D): void {

    if (!this.mAnimator) {
      return;
    }

    let center: MPPointF = this.mChart.getCenterCircleBox();

    // get whole the radius
    let radius: number = this.mChart.getRadius();
    let rotationAngle: number = this.mChart.getRotationAngle();
    let drawAngles: number[] = this.mChart.getDrawAngles();
    let absoluteAngles: number[] = this.mChart.getAbsoluteAngles();

    let phaseX: number = this.mAnimator.getPhaseX();
    let phaseY: number = this.mAnimator.getPhaseY();

    let roundedRadius: number = (radius - (radius * this.mChart.getHoleRadius() / 100)) / 2;
    let holeRadiusPercent: number = this.mChart.getHoleRadius() / 100.0;
    let labelRadiusOffset: number = radius / 10 * 3.6;

    if (this.mChart.isDrawHoleEnabled()) {
      labelRadiusOffset = (radius - (radius * holeRadiusPercent)) / 2;

      if (!this.mChart.isDrawSlicesUnderHoleEnabled() && this.mChart.isDrawRoundedSlicesEnabled()) {
        // Add curved circle slice and spacing to rotation angle, so that it sits nicely inside
        rotationAngle += roundedRadius * 360 / (Math.PI * 2 * radius);
      }
    }

    let labelRadius: number = radius - labelRadiusOffset;

    let data: PieData | null = this.mChart.getData();
    if (!data) {
      return;
    }
    let dataSets: JArrayList<IPieDataSet> = data.getDataSets();

    let yValueSum: number = data.getYValueSum();

    let drawEntryLabels: boolean = this.mChart.isDrawEntryLabelsEnabled();

    let angle: number;
    let xIndex: number = 0;

    c.save();

    let offset: number = Utils.handleDataValues(0.0);

    const lineHeight: number = Utils.getLabelTextSize(this.mValuePaint, "Q", this.textSizeCache)
      .height + Utils.handleDataValues(4);
    for (let i: number = 0; i < dataSets.size(); i++) {

      let dataSet: IPieDataSet = dataSets.get(i);

      let drawValues: boolean = dataSet.isDrawValuesEnabled();

      if (!drawValues && !drawEntryLabels)
        continue;

      let xValuePosition: ValuePosition = dataSet.getXValuePosition();
      let yValuePosition: ValuePosition = dataSet.getYValuePosition();

      // apply the text-styling defined by the DataSet
      this.applyValueTextStyle(dataSet);


      let formatter: IValueFormatter | null = dataSet.getValueFormatter();

      let entryCount: number = dataSet.getEntryCount();

      let isUseValueColorForLineEnabled: boolean = dataSet.isUseValueColorForLineEnabled();
      let valueLineColor: number = dataSet.getValueLineColor();

      this.mValueLinePaint.setStrokeWidth(Utils.handleDataValues(dataSet.getValueLineWidth()));

      let sliceSpace: number = this.getSliceSpace(dataSet);

      let iconsOffset: MPPointF = MPPointF.getInstance(undefined, undefined, dataSet.getIconsOffset());
      iconsOffset.x = Utils.handleDataValues(iconsOffset.x);
      iconsOffset.y = Utils.handleDataValues(iconsOffset.y);

      for (let j: number = 0; j < entryCount; j++) {

        let entry: PieEntry = dataSet.getEntryForIndex(j);

        if (xIndex == 0)
          angle = 0.0;
        else
          angle = absoluteAngles[xIndex - 1] * phaseX;

        let sliceAngle: number = drawAngles[xIndex];
        let sliceSpaceMiddleAngle: number = sliceSpace / (Utils.FDEG2RAD * labelRadius);

        // offset needed to center the drawn text in the slice
        let angleOffset: number = (sliceAngle - sliceSpaceMiddleAngle / 2.0) / 2.0;

        angle = angle + angleOffset;

        let transformedAngle: number = rotationAngle + angle * phaseY;

        let value: number = this.mChart.isUsePercentValuesEnabled() ? entry.getY()
                                                                      / yValueSum * 100 : entry.getY();
        let entryLabel: string = entry.getLabel();

        let sliceXBase: number = Math.cos(transformedAngle * Utils.FDEG2RAD);
        let sliceYBase: number = Math.sin(transformedAngle * Utils.FDEG2RAD);

        let drawXOutside: boolean = drawEntryLabels &&
        xValuePosition == ValuePosition.OUTSIDE_SLICE;
        let drawYOutside: boolean = drawValues &&
        yValuePosition == ValuePosition.OUTSIDE_SLICE;
        let drawXInside: boolean = drawEntryLabels &&
        xValuePosition == ValuePosition.INSIDE_SLICE;
        let drawYInside: boolean = drawValues &&
        yValuePosition == ValuePosition.INSIDE_SLICE;

        if (drawXOutside || drawYOutside) {

          let valueLineLength1: number = dataSet.getValueLinePart1Length();
          let valueLineLength2: number = dataSet.getValueLinePart2Length();
          let valueLinePart1OffsetPercentage: number = dataSet.getValueLinePart1OffsetPercentage() / 100.0;

          let pt2x: number = 0
          let pt2y: number = 0;
          let labelPtx: number = 0
          let labelPty: number = 0;

          let line1Radius: number = 0;

          if (this.mChart.isDrawHoleEnabled())
            line1Radius = (radius - (radius * holeRadiusPercent))
            * valueLinePart1OffsetPercentage
            + (radius * holeRadiusPercent);
          else
            line1Radius = radius * valueLinePart1OffsetPercentage;

          let polyline2Width: number = dataSet.isValueLineVariableLength()
            ? labelRadius * valueLineLength2 * /*(float)*/
              Math.abs(Math.sin(
                transformedAngle * Utils.FDEG2RAD))
            : labelRadius * valueLineLength2;

          let pt0x: number = line1Radius * sliceXBase + center.x;
          let pt0y: number = line1Radius * sliceYBase + center.y;

          let pt1x: number = labelRadius * (1 + valueLineLength1) * sliceXBase + center.x;
          let pt1y: number = labelRadius * (1 + valueLineLength1) * sliceYBase + center.y;

          if (transformedAngle % 360.0 >= 90.0 && transformedAngle % 360.0 <= 270.0) {
            pt2x = pt1x - polyline2Width;
            pt2y = pt1y;

            this.mValuePaint.setTextAlign("right" /*Align.RIGHT*/
            );

            if (drawXOutside)
              this.mEntryLabelsPaint.setTextAlign("right" /*Align.RIGHT*/
              );

            labelPtx = pt2x - offset;
            labelPty = pt2y;
          } else {
            pt2x = pt1x + polyline2Width;
            pt2y = pt1y;
            this.mValuePaint.setTextAlign("left" /*Align.LEFT*/
            );

            if (drawXOutside)
              this.mEntryLabelsPaint.setTextAlign("left" /*Align.LEFT*/
              );

            labelPtx = pt2x + offset;
            labelPty = pt2y;
          }

          let lineColor: number = ColorTemplate.COLOR_NONE;

          if (isUseValueColorForLineEnabled)
            lineColor = dataSet.getColor(j);
          else if (valueLineColor != ColorTemplate.COLOR_NONE)
            lineColor = valueLineColor;

          if (lineColor != ColorTemplate.COLOR_NONE) {
            this.mValueLinePaint.setColor(lineColor);
            Utils.resetContext2DWithoutFont(c, this.mValueLinePaint);
            c.beginPath();
            c.moveTo(pt0x, pt0y);
            c.lineTo(pt1x, pt1y);
            c.lineTo(pt2x, pt2y);
            c.stroke();
            c.closePath();
          }

          // draw everything, depending on settings
          if (drawXOutside && drawYOutside && formatter) {

            this.drawValue(c,
              formatter,
              value,
              entry,
              0,
              labelPtx,
              labelPty,
              dataSet.getValueTextColor(j));

            if (j < data.getEntryCount() && entryLabel != null) {
              this.drawEntryLabel(c, entryLabel, labelPtx, labelPty + lineHeight);
            }

          } else if (drawXOutside) {
            if (j < data.getEntryCount() && entryLabel != null) {
              this.drawEntryLabel(c, entryLabel, labelPtx, labelPty + lineHeight / 2.0);
            }
          } else if (drawYOutside && formatter) {

            this.drawValue(c, formatter, value, entry, 0, labelPtx, labelPty + lineHeight / 2.0, dataSet
              .getValueTextColor(j));
          }
        }

        if (drawXInside || drawYInside) {
          // calculate the text position
          let x: number = labelRadius * sliceXBase + center.x;
          let y: number = labelRadius * sliceYBase + center.y;

          this.mValuePaint.setTextAlign("center" /*Align.CENTER*/
          );

          // draw everything, depending on settings
          if (drawXInside && drawYInside && formatter) {

            this.drawValue(c, formatter, value, entry, 0, x, y, dataSet.getValueTextColor(j));

            if (j < data.getEntryCount() && entryLabel != null) {
              this.drawEntryLabel(c, entryLabel, x, y + lineHeight);
            }

          } else if (drawXInside) {
            if (j < data.getEntryCount() && entryLabel != null) {
              this.drawEntryLabel(c, entryLabel, x, y + lineHeight / 2);
            }
          } else if (drawYInside && formatter) {

            this.drawValue(c, formatter, value, entry, 0, x, y + lineHeight / 2, dataSet.getValueTextColor(j));
          }
        }

        if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {

          let icon: ChartPixelMap | null = entry.getIcon();

          let x: number = (labelRadius + iconsOffset.y) * sliceXBase + center.x;
          let y: number = (labelRadius + iconsOffset.y) * sliceYBase + center.y;
          y += iconsOffset.x;

          if (icon) {
              Utils.drawImage(
              c,
              icon,
              x,
              y,
              icon.getWidth(),
              icon.getHeight());
          }
        }

        xIndex++;
      }

      MPPointF.recycleInstance(iconsOffset);
    }
    MPPointF.recycleInstance(center);
    c.restore();
  }

  /**
   * Draws an entry label at the specified position.
   *
   * @param c
   * @param label
   * @param x
   * @param y
   */
  protected drawEntryLabel(c: CanvasRenderingContext2D, label: string, x: number, y: number): void {
    // c.drawText(label, x, y, this.mEntryLabelsPaint);
    Utils.resetContext2DWithoutLine(c, this.mEntryLabelsPaint);
    c.beginPath();
    c.fillText(label, x, y);
    c.closePath();
  }

  // @Override
  public drawExtras(c: CanvasRenderingContext2D): void {
    this.drawHole(c);
    // c.drawBitmap(this.mDrawBitmap.get([]), 0, 0, null);
    // c.drawImage(this.mDrawBitmap.get([]), 0, 0)
    this.drawCenterText(c);
  }

  private mHoleCirclePath: Path2D = new Path2D();

  /**
   * draws the hole in the center of the chart and the transparent circle /
   * hole
   */
  protected drawHole(c: CanvasRenderingContext2D): void {

    if (this.mChart.isDrawHoleEnabled()) {

      let radius: number = this.mChart.getRadius();
      let holeRadius: number = radius * (this.mChart.getHoleRadius() / 100);
      let center: MPPointF = this.mChart.getCenterCircleBox();

      // if (MyColor.alpha(Number(this.mHolePaint.getColor())) > 0) {
      // draw the hole-circle
      // this.mBitmapCanvas.drawCircle(
      //           center.x, center.y,
      //           holeRadius, this.mHolePaint);

      Utils.resetContext2DWithoutFont(c, this.mHolePaint);
      c.beginPath();
      c.arc(center.x, center.y, holeRadius, 0, 2 * Math.PI)
      c.fill();
      c.closePath();
      // }

      // only draw the circle if it can be seen (not covered by the hole)
      // if (MyColor.alpha(Number(this.mTransparentCirclePaint.getColor())) > 0 &&
      //   this.mChart.getTransparentCircleRadius() > this.mChart.getHoleRadius()) {

      let alpha: number | undefined = this.mTransparentCirclePaint.getGlobalAlpha();
      let secondHoleRadius: number = radius * (this.mChart.getTransparentCircleRadius() / 100);
      if (!this.mAnimator) {
        return;
      }

      if (alpha) {
        this.mTransparentCirclePaint.setGlobalAlpha( /*(int)*/
          ( /*(float) */
            alpha * this.mAnimator.getPhaseX() * this.mAnimator.getPhaseY()));
      }

      c.save();
      Utils.resetContext2DWithoutFont(c, this.mTransparentCirclePaint);

      c.beginPath();
      c.arc(center.x, center.y, secondHoleRadius, 0, 2 * Math.PI, true)
      c.arc(center.x, center.y, holeRadius, 0, 2 * Math.PI, false)
      c.fill()
      c.closePath();
      c.restore();

      // reset alpha
      if (alpha) {
        this.mTransparentCirclePaint.setGlobalAlpha(alpha);
      }
      // }
      MPPointF.recycleInstance(center);
    }
  }

  protected mDrawCenterTextPathBuffer: Path2D = new Path2D();

  /**
   * draws the description text in the center of the pie chart makes most
   * sense when center-hole is enabled
   */
  protected drawCenterText(c: CanvasRenderingContext2D): void {

    let centerText: string = this.mChart.getCenterText();

    if (this.mChart.isDrawCenterTextEnabled() && centerText != null) {

      let center: MPPointF = this.mChart.getCenterCircleBox();
      let offset: MPPointF = this.mChart.getCenterTextOffset();

      let x: number = center.x + offset.x;
      let y: number = center.y + offset.y;

      let innerRadius: number = this.mChart.isDrawHoleEnabled() && !this.mChart.isDrawSlicesUnderHoleEnabled()
        ? this.mChart.getRadius() * (this.mChart.getHoleRadius() / 100)
        : this.mChart.getRadius();

      let holeRect: MyRect = this.mRectBuffer[0];
      holeRect.left = x - innerRadius;
      holeRect.top = y - innerRadius;
      holeRect.right = x + innerRadius;
      holeRect.bottom = y + innerRadius;
      let boundingRect: MyRect = this.mRectBuffer[1];
      boundingRect.set(holeRect.left, holeRect.top, holeRect.right, holeRect.bottom);

      let radiusPercent: number = this.mChart.getCenterTextRadiusPercent() / 100;
      if (radiusPercent > 0.0) {
        boundingRect.inset(
          (boundingRect.width() - boundingRect.width() * radiusPercent) / 2.0,
          (boundingRect.height() - boundingRect.height() * radiusPercent) / 2.0,
          (boundingRect.width() - boundingRect.width() * radiusPercent) / 2.0,
          (boundingRect.height() - boundingRect.height() * radiusPercent) / 2.0
        );
      }

      if (centerText != this.mCenterTextLastValue || boundingRect != this.mCenterTextLastBounds) {

        // Next time we won't recalculate StaticLayout...
        this.mCenterTextLastBounds.set(boundingRect.left, boundingRect.top, boundingRect.right, boundingRect.bottom);
        this.mCenterTextLastValue = centerText;
      }

      let textWidth: number = Utils.getLabelTextSize(this.mCenterTextPaint, centerText, this.textSizeCache).width;
      c.save();
      Utils.resetContext2DWithoutLine(c, this.mCenterTextPaint);
      c.fillText(centerText, x - textWidth / 2, y);
      c.restore();
      MPPointF.recycleInstance(center);
      MPPointF.recycleInstance(offset);
    }
  }

  protected mDrawHighlightedRectF: MyRect = new MyRect();

  // @Override
  public drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[]): void {

    /* Skip entirely if using rounded circle slices, because it doesn't make sense to highlight
     * in this way.
     */

    let drawInnerArc: boolean = this.mChart.isDrawHoleEnabled() && !this.mChart.isDrawSlicesUnderHoleEnabled();
    if (drawInnerArc && this.mChart.isDrawRoundedSlicesEnabled())
      return;

    if (!this.mAnimator) {
      return;
    }
    let phaseX: number = this.mAnimator.getPhaseX();
    let phaseY: number = this.mAnimator.getPhaseY();

    let angle: number;
    let rotationAngle: number = this.mChart.getRotationAngle();

    let drawAngles: number[] = this.mChart.getDrawAngles();
    let absoluteAngles: number[] = this.mChart.getAbsoluteAngles();
    let center: MPPointF = this.mChart.getCenterCircleBox();
    let radius: number = this.mChart.getRadius();
    let userInnerRadius: number = drawInnerArc
      ? radius * (this.mChart.getHoleRadius() / 100.0)
      : 0.0;

    let highlightedCircleBox: MyRect = this.mDrawHighlightedRectF;
    highlightedCircleBox.set(0, 0, 0, 0);

    for (let i: number = 0; i < indices.length; i++) {

      // get the index to highlight
      let index: number = /*(int)*/
      indices[i].getX();

      if (index >= drawAngles.length)
        continue;

      let chartData = this.mChart.getData();
      if (!chartData) {
        continue;
      }

      let set: IPieDataSet | null = chartData.getDataSetByIndex(indices[i].getDataSetIndex());

      if (set == null || !set.isHighlightEnabled())
        continue;

      let entryCount: number = set.getEntryCount();
      let visibleAngleCount: number = 0;
      for (let j: number = 0; j < entryCount; j++) {
        // draw only if the value is greater than zero
        if ((Math.abs(set.getEntryForIndex(j).getY()) > Utils.FLOAT_EPSILON)) {
          visibleAngleCount++;
        }
      }

      if (index == 0)
        angle = 0.0;
      else
        angle = absoluteAngles[index - 1] * phaseX;

      let sliceSpace: number = visibleAngleCount <= 1 ? 0.0 : set.getSliceSpace();

      let sliceAngle: number = drawAngles[index];
      let innerRadius: number = userInnerRadius;

      let shift: number = set.getSelectionShift();
      let highlightedRadius: number = radius + shift;
      highlightedCircleBox.set(this.mChart.getCircleBox().left, this.mChart.getCircleBox()
        .top, this.mChart.getCircleBox().right, this.mChart.getCircleBox().bottom);
      highlightedCircleBox.inset(-shift, -shift, -shift, -shift);

      let accountForSliceSpacing: boolean = sliceSpace > 0.0 && sliceAngle <= 180.0;

      let highlightColor: number | null = set.getHighlightColor();
      if (highlightColor == null) {
        highlightColor = set.getColor(index);
      }
      if (highlightColor) {
        this.mRenderPaint.setColor(highlightColor);
      }

      let sliceSpaceAngleOuter: number = visibleAngleCount == 1 ?
        0.0 :
        sliceSpace / (Utils.FDEG2RAD * radius);

      let sliceSpaceAngleShifted: number = visibleAngleCount == 1 ?
        0.0 :
        sliceSpace / (Utils.FDEG2RAD * highlightedRadius);

      let startAngleOuter: number = rotationAngle + (angle + sliceSpaceAngleOuter / 2.0) * phaseY;
      let sweepAngleOuter: number = (sliceAngle - sliceSpaceAngleOuter) * phaseY;
      if (sweepAngleOuter < 0.0) {
        sweepAngleOuter = 0;
      }

      let startAngleShifted: number = rotationAngle + (angle + sliceSpaceAngleShifted / 2.0) * phaseY;
      let sweepAngleShifted: number = (sliceAngle - sliceSpaceAngleShifted) * phaseY;
      if (sweepAngleShifted < 0.0) {
        sweepAngleShifted = 0.0;
      }

      // this.mPathBuffer.reset();
      this.mPathBuffer = new Path2D();

      if (sweepAngleOuter >= 360.0 && sweepAngleOuter % 360 <= Utils.FLOAT_EPSILON) {
        // ohos is doing "mod 360"
        this.mPathBuffer.arc(center.x, center.y, highlightedRadius, 0, 2 * Math.PI, false);

      } else {

        this.mPathBuffer.moveTo(
          center.x + highlightedRadius * /*(float)*/
          Math.cos(startAngleShifted * Utils.FDEG2RAD),
          center.y + highlightedRadius * /*(float)*/
          Math.sin(startAngleShifted * Utils.FDEG2RAD));

        this.arcTo(this.mPathBuffer, highlightedCircleBox,
          startAngleShifted,
          sweepAngleShifted)
      }

      let sliceSpaceRadius = 0.0;
      if (accountForSliceSpacing) {
        sliceSpaceRadius =
        this.calculateMinimumRadiusForSpacedSlice(
          center, radius,
          sliceAngle * phaseY,
          center.x + radius * /*(float)*/
          Math.cos(startAngleOuter * Utils.FDEG2RAD),
          center.y + radius * /*(float)*/
          Math.sin(startAngleOuter * Utils.FDEG2RAD),
          startAngleOuter,
          sweepAngleOuter);
      }

      // API < 21 does not receive floats in addArc, but a RectF
      this.mInnerRectBuffer.set(
        center.x - innerRadius,
        center.y - innerRadius,
        center.x + innerRadius,
        center.y + innerRadius);

      if (drawInnerArc &&
      (innerRadius > 0.0 || accountForSliceSpacing)) {

        if (accountForSliceSpacing) {
          let minSpacedRadius = sliceSpaceRadius;

          if (minSpacedRadius < 0.0)
            minSpacedRadius = -minSpacedRadius;

          innerRadius = Math.max(innerRadius, minSpacedRadius);
        }

        let sliceSpaceAngleInner: number = visibleAngleCount == 1 || innerRadius == 0.0 ?
          0.0 :
          sliceSpace / (Utils.FDEG2RAD * innerRadius);
        let startAngleInner: number = rotationAngle + (angle + sliceSpaceAngleInner / 2.0) * phaseY;
        let sweepAngleInner: number = (sliceAngle - sliceSpaceAngleInner) * phaseY;
        if (sweepAngleInner < 0.0) {
          sweepAngleInner = 0.0;
        }
        let endAngleInner: number = startAngleInner + sweepAngleInner;

        if (sweepAngleOuter >= 360.0 && sweepAngleOuter % 360 <= Utils.FLOAT_EPSILON) {
          // ohos is doing "mod 360"
          this.mPathBuffer.arc(center.x, center.y, innerRadius, 0, 2 * Math.PI, true);

        } else {

          this.mPathBuffer.lineTo(
            center.x + innerRadius * /*(float)*/
            Math.cos(endAngleInner * Utils.FDEG2RAD),
            center.y + innerRadius * /*(float)*/
            Math.sin(endAngleInner * Utils.FDEG2RAD));

          this.arcTo(this.mPathBuffer, this.mInnerRectBuffer, endAngleInner, -sweepAngleInner);
        }
      } else {

        if (sweepAngleOuter % 360 > Utils.FLOAT_EPSILON) {

          if (accountForSliceSpacing) {
            let angleMiddle: number = startAngleOuter + sweepAngleOuter / 2.0;

            let arcEndPointX: number = center.x +
            sliceSpaceRadius * /*(float)*/
            Math.cos(angleMiddle * Utils.FDEG2RAD);
            let arcEndPointY: number = center.y +
            sliceSpaceRadius * /*(float)*/
            Math.sin(angleMiddle * Utils.FDEG2RAD);

            this.mPathBuffer.lineTo(
              arcEndPointX,
              arcEndPointY);

          } else {

            this.mPathBuffer.lineTo(
              center.x,
              center.y);
          }

        }

      }

      this.mPathBuffer.closePath();

      // this.mBitmapCanvas.drawPath(this.mPathBuffer, this.mRenderPaint);
      Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
      c.beginPath();
      // c.stroke(this.mPathBuffer);
      c.fill(this.mPathBuffer);
      c.closePath();
    }
    MPPointF.recycleInstance(center);
  }

  /**
   * This gives all pie-slices a rounded edge.
   *
   * @param c
   */
  protected drawRoundedSlices(c: CanvasRenderingContext2D): void {

    if (!this.mChart.isDrawRoundedSlicesEnabled() || !this.mAnimator || !this.mChart.getData())
      return;

    let dataSet: IPieDataSet = this.mChart.getData()!.getDataSet();

    if (!dataSet.isVisible())
      return;

    let phaseX: number = this.mAnimator.getPhaseX();
    let phaseY: number = this.mAnimator.getPhaseY();

    let center: MPPointF = this.mChart.getCenterCircleBox();
    let r: number = this.mChart.getRadius();

    // calculate the radius of the "slice-circle"
    let circleRadius: number = (r - (r * this.mChart.getHoleRadius() / 100)) / 2;

    let drawAngles: number[] = this.mChart.getDrawAngles();
    let angle: number = this.mChart.getRotationAngle();

    for (let j: number = 0; j < dataSet.getEntryCount(); j++) {

      let sliceAngle: number = drawAngles[j];

      let e: EntryOhos = dataSet.getEntryForIndex(j);

      // draw only if the value is greater than zero
      if ((Math.abs(e.getY()) > Utils.FLOAT_EPSILON)) {

        let x: number = /*(float) */
          ((r - circleRadius)
          * Math.cos(MyMath.toRadians((angle + sliceAngle)
          * phaseY)) + center.x);
        let y: number = /*(float)*/
          ((r - circleRadius)
          * Math.sin(MyMath.toRadians((angle + sliceAngle)
          * phaseY)) + center.y);

        this.mRenderPaint.setColor(dataSet.getColor(j));
        // this.mBitmapCanvas.drawCircle(x, y, circleRadius, this.mRenderPaint);
        Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
        c.beginPath();
        c.arc(center.x, center.y, circleRadius, 0, 2 * Math.PI)
        c.fill();
        c.closePath();

      }

      angle += sliceAngle * phaseX;
    }
    MPPointF.recycleInstance(center);
  }

  /**
   * Releases the drawing bitmap. This should be called when {@link LineChart#onDetachedFromWindow()}.
   */
  public releaseBitmap(): void {
    // if (this.mBitmapCanvas != null) {
    //   this.mBitmapCanvas.setBitmap(null);
    //   this.mBitmapCanvas = null;
    // }
    // if (this.mDrawBitmap != null) {
    //     let drawBitmap:Bitmap = this.mDrawBitmap.get([]);
    //     if (drawBitmap != null) {
    //         drawBitmap.recycle();
    //     }
    //     this.mDrawBitmap.clear();
    //   this.mDrawBitmap = null;
    // }
  }

  private arcTo(path: Path2D, roundedCircleBox: MyRect, startAngle: number, sweepAngle: number): void {
    path.ellipse(roundedCircleBox.left + (roundedCircleBox.right - roundedCircleBox.left) / 2,
      roundedCircleBox.top + (roundedCircleBox.bottom - roundedCircleBox.top) / 2,
      (roundedCircleBox.right - roundedCircleBox.left) / 2,
      (roundedCircleBox.bottom - roundedCircleBox.top) / 2,
      0,
      startAngle * Utils.DEG2RAD,
      (startAngle + sweepAngle) * Utils.DEG2RAD,
        sweepAngle < 0 ? true : false);
  }
}
