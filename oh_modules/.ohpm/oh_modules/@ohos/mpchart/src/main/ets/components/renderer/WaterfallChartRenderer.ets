/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

import BarChartRenderer from './BarChartRenderer';
import ChartPixelMap from '../data/ChartPixelMap';
import Fill, { FillDirection } from '../utils/Fill';
import Highlight from '../highlight/Highlight';
import { JArrayList } from '../utils/JArrayList';
import MPPointF from '../utils/MPPointF';
import MyRect from '../data/Rect';
import { Style } from '../data/Paint';
import Transformer from '../utils/Transformer';
import Utils from '../utils/Utils';
import WaterfallBuffer from '../buffer/WaterfallBuffer';
import WaterfallEntry, { WaterfallHighlight } from '../data/WaterfallEntry';
import WaterfallDataSet from '../data/WaterfallDataSet';
import IValueFormatter from '../formatter/IValueFormatter';
import WaterfallData from '../data/WaterfallData';
import IWaterfallDataSet from '../interfaces/datasets/IWaterfallDataSet';
import WaterfallDataProvider from '../interfaces/dataprovider/WaterfallDataProvider';
import ChartAnimator from '../animation/ChartAnimator';
import ViewPortHandler from '../utils/ViewPortHandler';
import HashMap from '@ohos.util.HashMap';

export default class WaterfallChartRenderer extends BarChartRenderer {
  protected mBarBuffers: WaterfallBuffer[] = new Array<WaterfallBuffer>();
  public mChart: WaterfallDataProvider | null = null;
  textSizeCache = new HashMap<string, TextMetrics>();

  constructor(chart: WaterfallDataProvider, animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(chart, animator, viewPortHandler);
    this.mChart = chart;
  }

  public initBuffers(): void {
    if (!this.mChart) {
      return;
    }
    let data: WaterfallData | null = this.mChart.getWaterfallData();
    if (data) {
      this.mBarBuffers = new Array(data.getDataSetCount());
      for (let i = 0; i < this.mBarBuffers.length; i++) {
        let dataSet: IWaterfallDataSet | null = data.getDataSetByIndex(i) as IWaterfallDataSet;
        if (dataSet) {
          this.mBarBuffers[i] = new WaterfallBuffer(dataSet.getEntryCount() * 4 * (dataSet.isStacked() ? dataSet.getStackSize() : 1),
            data.getDataSetCount(), dataSet.isStacked());
        }
      }
    }
  }

  protected mWaterfallShadowRectBuffer: MyRect = new MyRect();

  public drawData(c: CanvasRenderingContext2D): void {

    if (!this.mChart) {
      return
    }
    let data: WaterfallData | null = this.mChart.getWaterfallData();
    if (data) {
      for (let i = 0; i < data.getDataSetCount(); i++) {
        let set: IWaterfallDataSet | null = data.getDataSetByIndex(i) as IWaterfallDataSet;

        if (set && set.isVisible()) {
          this.drawDataSet(c, set as WaterfallDataSet, i);
        }
      }
    }
  }

  protected drawDataSet(c: CanvasRenderingContext2D, dataSet: WaterfallDataSet, index: number): void {

    if (!this.mChart) {
      return;
    }
    let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());

    if (this.mBarBorderPaint) {
      this.mBarBorderPaint.setColor(dataSet.getBarBorderColor());
      this.mBarBorderPaint.setStrokeWidth(Utils.handleDataValues(dataSet.getBarBorderWidth()));

    }

    const drawBorder: boolean = dataSet.getBarBorderWidth() > 0.0;

    let phaseX: number = 1;
    let phaseY: number = 1;
    if (this.mAnimator) {
      phaseX = this.mAnimator.getPhaseX();
      phaseY = this.mAnimator.getPhaseY();
    }

    // draw the bar shadow before the values
    if (this.mShadowPaint && this.mChart.isDrawBarShadowEnabled()) {
      this.mShadowPaint.setColor(dataSet.getBarShadowColor());

      let waterfallData: WaterfallData | null = this.mChart.getWaterfallData();
      if (!waterfallData) {
        return;
      }
      const barWidth: number = waterfallData.getBarWidth();
      const barWidthHalf: number = barWidth / 2.0;
      let x: number = 0;

      for (let i = 0,
        count = Math.min(Number(Math.ceil(Number(dataSet.getEntryCount()) * phaseX)), dataSet.getEntryCount()); i < count; i++) {

        let e: WaterfallEntry = dataSet.getEntryForIndex(i) as WaterfallEntry;

        x = e.getX();

        this.mWaterfallShadowRectBuffer.left = x - barWidthHalf;
        this.mWaterfallShadowRectBuffer.right = x + barWidthHalf;

        if (trans) {
          trans.rectValueToPixel(this.mWaterfallShadowRectBuffer);
        }

        if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsLeft(this.mWaterfallShadowRectBuffer.right)) {
          continue;
        }

        if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(this.mWaterfallShadowRectBuffer.left)) {
          break;
        }

        this.mWaterfallShadowRectBuffer.top = this.mViewPortHandler ? this.mViewPortHandler.contentTop() : 0;
        this.mWaterfallShadowRectBuffer.bottom = this.mViewPortHandler ? this.mViewPortHandler.contentBottom() : 0;
        if (this.mShadowPaint) {
          Utils.resetContext2DWithoutFont(c, this.mShadowPaint);
          c.beginPath();
          c.rect(this.mWaterfallShadowRectBuffer.left, this.mWaterfallShadowRectBuffer.top, this.mWaterfallShadowRectBuffer.width(), this.mWaterfallShadowRectBuffer.height())
          switch (this.mShadowPaint.getStyle()) {
            case Style.STROKE:
              c.stroke();
              break;
            case Style.FILL:
            case Style.FILL_AND_STROKE:
            default:
              c.fill();
              break;
          }
          c.closePath();
        }
      }
    }

    // initialize the buffer
    let buffer: WaterfallBuffer = this.mBarBuffers[index];
    buffer.setPhases(phaseX, phaseY);
    buffer.setDataSet(index);
    buffer.setInverted(this.mChart.isInverted(dataSet.getAxisDependency()));
    let waterfallData: WaterfallData | null = this.mChart.getWaterfallData();
    if (waterfallData) {
      buffer.setBarWidth(waterfallData.getBarWidth());
    }

    buffer.feed(dataSet);
    if (trans) {
      trans.pointValuesToPixel(buffer.buffer);
    }

    let fills: JArrayList<Fill> | null = dataSet.getFills();
    const isCustomFill: boolean = !!fills && !fills.isEmpty();
    const isSingleColor: boolean = dataSet.getColors().size() == 1;
    const isInverted: boolean = this.mChart.isInverted(dataSet.getAxisDependency());

    if (isSingleColor) {
      this.mRenderPaint.setColor(dataSet.getColor());
      const opacity = dataSet.getOpacity();
      this.mRenderPaint.globalAlpha = opacity / 100;
    }

    let arrayTop = buffer.getArrayTop();
    let maxTop = arrayTop[0];
    for (let i = 1; i < arrayTop.length; i++) {
      if (arrayTop[i] > maxTop) {
        maxTop = arrayTop[i];
      }
    }

    let arrayBottom = buffer.getArrayBottom();
    let minBottom = arrayBottom[0];

    for (let i = 1; i < arrayBottom.length; i++) {
      if (arrayBottom[i] < minBottom) {
        minBottom = arrayBottom[i];
      }
    }

    if (dataSet.getEnableMaxOrMinHighlightColor()) {
      for (let i = 0,
        count = Math.min(Number(Math.ceil(Number(dataSet.getEntryCount()) * phaseX)), dataSet.getEntryCount()); i < count; i++) {
        let e: WaterfallEntry = dataSet.getEntryForIndex(i) as WaterfallEntry;
        this.initMaxAndMinHighlightData(e, dataSet, maxTop, minBottom);
      }
    }
    // 获取Y轴刻度范围数据
    let yAxisSegmentList = dataSet.getYAxisSegmentationColors();

    for (let j = 0, pos = 0; j < buffer.size(); j += 4, pos++) {

      if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsLeft(buffer.buffer[j + 2]))
        continue;
      if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(buffer.buffer[j]))
        break;
      if (!isSingleColor) {
        // Set the color for the currently drawn value. If the index
        // is out of bounds, reuse colors.
        this.mRenderPaint.setColor(dataSet.getColor(pos));
      }

      if (isCustomFill) {

        let fill: Fill | null = dataSet.getFill(pos);
        if (fill) {
          fill.fillRect(
            c, this.mRenderPaint,
            buffer.buffer[j],
            buffer.buffer[j + 1],
            buffer.buffer[j + 2],
            buffer.buffer[j + 3],
            isInverted ? FillDirection.DOWN : FillDirection.UP);
        }

      } else {
        if (this.mRenderPaint) {
          Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
        }

        let left: number = buffer.buffer[j];
        let bottom: number = buffer.buffer[j + 1];
        let right: number = buffer.buffer[j + 2];
        let top: number = buffer.buffer[j + 3];

        //绘制数据
        let radius = (right - left) / 2;
        let path = new Path2D();
        let outBarIsEllipse = false;
        if (Math.abs(top - bottom) > (right - left)) {
          path = this.drawRoundedRectangles(c, left, top, right, bottom, radius);
        } else {
          outBarIsEllipse = true;
          path = this.drawEllipse(c, left, top, right, bottom);
        }

        let e: WaterfallEntry = dataSet.getEntryForIndex(j / 4) as WaterfallEntry;
        //绘制Y轴刻度范围图
        for (let i = 0; i < yAxisSegmentList.length; i++) {
          let h = yAxisSegmentList[i];
          //canvas画布的y轴与图表的y轴方向相反
          let maxY = h.getMinY();
          let minY = h.getMaxY();
          if (maxY > e.getMaxY() || (minY < e.getMaxY() && minY < e.getMinY())) {
            continue;
          }
          maxY = maxY <= e.getMinY() ? e.getMinY() : maxY;
          minY = minY >= e.getMaxY() ? e.getMaxY() : minY;
          let yArray = [0, minY, 0, maxY];
          trans?.pointValuesToPixel(yArray);
          if (Math.abs(yArray[1] - yArray[3]) > (right - left)) {
            c.save();
            c.fillStyle = h.getColor();
            this.drawWaterfallBar(c, left, right, radius, yArray, e, minY, maxY);
            c.restore();
          } else {
            if (h.getMaxY() > e.getMaxY() || h.getMinY() < e.getMinY()) {
              continue;
            }
            c.save();
            c.fillStyle = h.getColor();
            if (yArray[3] + 2 * radius > bottom) {
              this.drawCircle(c, left, bottom - 2 * radius, radius);
            } else {
              this.drawCircle(c, left, yArray[3], radius);
            }
            c.restore();
          }
        }

        let highlights = e.getHighlights();
        let topNum = this.getHighlightTop(e);
        //绘制标记点
        for (let i = 0; i < highlights.length; i++) {
          let h = highlights[i];
          //canvas画布的y轴与图表的y轴方向相反
          let maxY = h.getMinY();
          let minY = h.getMaxY();
          let yArray = [0, minY, 0, maxY];
          trans?.pointValuesToPixel(yArray);
          if (yArray[1] == yArray[3]) {
            c.save();
            c.fillStyle = h.getColor();
            c.clip(path);
            if (outBarIsEllipse) {
              this.drawEllipse(c, left, top, right, bottom);
            } else {
              if (yArray[1] == top) {
                //绘制最高点
                this.drawEllipse(c, left, top, right, top + radius * 2);
              } else {
                //绘制最低点
                this.drawEllipse(c, left, bottom - radius * 2, right, bottom);
              }
            }
            c.restore();
            continue;
          }
          c.save();
          c.fillStyle = h.getColor();
          c.clip(path);
          if (e.getHighlights().length === 1) {
            this.drawRoundedRectangles(c, left, yArray[1], right, yArray[3], radius);
          } else {
            this.drawHighlights(c, left, radius, yArray, i, right, h, topNum, outBarIsEllipse);
          }
          c.restore();
        }
      }

      if (drawBorder) {
        if (this.mBarBorderPaint) {
          Utils.resetContext2DWithoutFont(c, this.mBarBorderPaint);
        }
        c.beginPath();
        c.rect(buffer.buffer[j], buffer.buffer[j + 1], buffer.buffer[j + 2] - buffer.buffer[j], buffer.buffer[j + 3] - buffer.buffer[j + 1]);
        c.stroke();
        c.closePath();
      }
    }
    dataSet.setMaxTopHighlightEXIST(false);
    dataSet.setMinBottomHighlightEXIST(false);
  }

  protected drawHighlights(c: CanvasRenderingContext2D, left: number, radius: number, yArray: number[], i: number, right: number, h: WaterfallHighlight, topNum: number, outBarIsEllipse: boolean) {
    c.beginPath();
    c.moveTo(left + radius, yArray[1]);
    if (outBarIsEllipse) {
      this.drawEllipse(c, left, yArray[1], right, yArray[3]);
      return;
    }
    if (i === 0) {
      this.drawBottomCircularCylinder(c, right, yArray, radius, left);
    } else if (h.getMaxY() === topNum) {
      c.lineTo(right - radius, yArray[1]);
      c.arc(right - radius, yArray[1] + radius, radius, 3 / 2 * Math.PI, 0);
      c.lineTo(right, yArray[3]);
      c.lineTo(left, yArray[3]);
      c.lineTo(left, yArray[1] + radius);
      c.arc(left + radius, yArray[1] + radius, radius, Math.PI, 3 / 2 * Math.PI);
    } else {
      c.rect(left, yArray[1], right - left, yArray[3] - yArray[1]);
    }
    c.closePath();
    c.fill();
  }

  protected drawBottomCircularCylinder(c: CanvasRenderingContext2D, right: number, yArray: number[], radius: number, left: number) {
    c.lineTo(right, yArray[1]);
    c.lineTo(right, yArray[3] - radius);
    c.arc(right - radius, yArray[3] - radius, radius, 0, Math.PI / 2);
    c.lineTo(left + radius, yArray[3]);
    c.arc(left + radius, yArray[3] - radius, radius, Math.PI / 2, Math.PI);
    c.lineTo(left, yArray[1]);
  }

  protected getHighlightTop(e: WaterfallEntry) {
    let topNum = 0;
    for (let i = 0; i < e.getHighlights().length; i++) {
      if (e.getHighlights()[i].getMaxY() === e.getHighlights()[i].getMinY()) {
        continue;
      }
      topNum = e.getHighlights()[i].getMaxY() > topNum ? e.getHighlights()[i].getMaxY() : topNum;
    }
    return topNum;
  }

  protected drawWaterfallBar(c: CanvasRenderingContext2D, left: number, right: number, radius: number, yArray: number[], e: WaterfallEntry, minY: number, maxY: number) {
    c.beginPath(); // 开始绘制路径
    c.moveTo(left + radius, yArray[1]); // 移动到指定位置
    if (e.getMaxY() === minY && e.getMinY() === maxY) { // 判断是否为最大值和最小值
      this.drawRoundedRectangles(c, left, yArray[1], right, yArray[3], radius); // 调用绘制圆角矩形方法
    } else if (e.getMaxY() === minY) { // 判断是否为最大值
      c.lineTo(right - radius, yArray[1]);
      c.arc(right - radius, yArray[1] + radius, radius, 3 / 2 * Math.PI, 0);
      c.lineTo(right, yArray[3]);
      c.lineTo(left, yArray[3]);
      c.lineTo(left, yArray[1] + radius);
      c.arc(left + radius, yArray[1] + radius, radius, Math.PI, 3 / 2 * Math.PI);
    } else if (e.getMinY() === maxY) {
      this.drawBottomCircularCylinder(c, right, yArray, radius, left); // 调用绘制底部圆柱方法
    } else {
      c.rect(left, yArray[1], right - left, yArray[3] - yArray[1]); // 绘制矩形
    }
    c.closePath(); // 结束路径
    c.fill(); // 填充路径
  }

  protected drawEllipse(c: CanvasRenderingContext2D, left: number, top: number, right: number, bottom: number): Path2D {
    let path = new Path2D();
    const centerX = (left + right) / 2;
    const centerY = (top + bottom) / 2;
    const radiusX = (right - left) / 2;
    const radiusY = (bottom - top) / 2;
    path.ellipse(centerX, centerY, radiusX, radiusY, 0, 0, 2 * Math.PI);
    path.closePath();
    c.fill(path);
    return path;
  }

  protected drawRect(c: CanvasRenderingContext2D, left: number, top: number, right: number, bottom: number) {
    c.moveTo(left, top);
    c.lineTo(left, bottom);
    c.lineTo(right, bottom);
    c.lineTo(right, top);
    c.lineTo(left, top);
    c.fill();
  }

  protected drawCircle(c: CanvasRenderingContext2D, left: number, top: number, radius: number) {
    c.beginPath();
    c.arc(left + radius, top + radius, radius, 0, 2 * Math.PI);
    c.closePath();
    c.fill();
  }

  protected drawRoundedRectangles(c: CanvasRenderingContext2D, left: number, top: number, right: number, bottom: number, radius: number): Path2D {
    let path = new Path2D();
    path.moveTo(left + radius, top);
    path.lineTo(right - radius, top);
    path.arc(right - radius, top + radius, radius, 3 / 2 * Math.PI, 0);
    path.lineTo(right, bottom - radius);
    path.arc(right - radius, bottom - radius, radius, 0, Math.PI / 2);
    path.lineTo(left + radius, bottom);
    path.arc(left + radius, bottom - radius, radius, Math.PI / 2, Math.PI);
    path.lineTo(left, top + radius);
    path.arc(left + radius, top + radius, radius, Math.PI, 3 / 2 * Math.PI);
    path.closePath();
    c.fill(path);
    return path;
  }

  protected initMaxAndMinHighlightData(e: WaterfallEntry, dataSet: WaterfallDataSet, maxTop: number, minBottom: number) {
    if (maxTop === e.getMaxY() && !dataSet.getMaxTopHighlightEXIST()) {
      dataSet.setMaxTopHighLightEXIST(true);
      e.setHighlights(new WaterfallHighlight(maxTop, maxTop, dataSet.getMaxyHighlightColor()));
    }
    if (minBottom === e.getMinY() && !dataSet.getMinBottomHighlightEXIST()) {
      dataSet.setMinBottomHighlightEXIST(true);
      e.setHighlights(new WaterfallHighlight(minBottom, minBottom, dataSet.getMinyHighlightColor()));
    }
  }

  // @Override
  public drawValues(c: CanvasRenderingContext2D): void {
    if (!this.mChart || !this.mChart.getWaterfallData()) {
      return;
    }
    // if values are drawn
    if (this.isDrawingValuesAllowed(this.mChart)) {
      let waterfallData: WaterfallData | null = this.mChart.getWaterfallData();
      if (!waterfallData) {
        return;
      }
      let dataSets: JArrayList<IWaterfallDataSet> = waterfallData.getDataSets();

      const valueOffsetPlus: number = 0;
      let posOffset: number = 0;
      let negOffset: number = 0;
      let drawValueAboveBar: boolean = this.mChart.isDrawValueAboveBarEnabled();

      for (let i = 0; i < waterfallData.getDataSetCount(); i++) {

        let dataSet: IWaterfallDataSet = dataSets.get(i);

        if (!this.shouldDrawValues(dataSet))
          continue;

        // apply the text-styling defined by the DataSet
        this.applyValueTextStyle(dataSet);

        let isInverted: boolean = this.mChart.isInverted(dataSet.getAxisDependency());

        // calculate the correct offset depending on the draw position of
        // the value
        let valueTextHeight: number = Utils.getLabelTextSize(this.mValuePaint, "8", this.textSizeCache).height;
        posOffset = (drawValueAboveBar ? -valueOffsetPlus : valueTextHeight + valueOffsetPlus);
        negOffset = (drawValueAboveBar ? valueTextHeight + valueOffsetPlus : -valueOffsetPlus);

        if (isInverted) {
          posOffset = -posOffset - valueTextHeight;
          negOffset = -negOffset - valueTextHeight;
        }

        // get the buffer
        let buffer: WaterfallBuffer = this.mBarBuffers[i];

        let iconsOffset: MPPointF = MPPointF.getInstance(0, 0, dataSet.getIconsOffset());
        iconsOffset.x = Utils.handleDataValues(iconsOffset.x);
        iconsOffset.y = Utils.handleDataValues(iconsOffset.y);

        for (let j = 0; j < buffer.buffer.length * (this.mAnimator ? this.mAnimator.getPhaseX() : 1); j += 4) {

          let x: number = (buffer.buffer[j] + buffer.buffer[j + 2]) / 2;

          if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(x))
            break;

          if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsY(buffer.buffer[j + 1])
            || !this.mViewPortHandler.isInBoundsLeft(x))
            continue;

          let entry: WaterfallEntry = dataSet.getEntryForIndex(j / 4) as WaterfallEntry;
          let val: number = entry.getY();

          if (dataSet.isDrawValuesEnabled()) {
            let valueFormatter: IValueFormatter | null = dataSet.getValueFormatter();
            if (valueFormatter) {
              this.drawValue(c, valueFormatter, val, entry, i, x,
                (buffer.buffer[j + 3] + posOffset),
                dataSet.getValueTextColor(j / 4));
            }
          }
          let icon: ChartPixelMap | null = entry.getIcon();
          if (icon && dataSet.isDrawIconsEnabled()) {
            let px: number = x+iconsOffset.x;
            let py: number = buffer.buffer[j + 3] +posOffset+ iconsOffset.y
            Utils.drawImage(
              c,
              icon,
              Utils.parseInt(px),
              Utils.parseInt(py),
              icon.getWidth(),
              icon.getHeight());
          }
        }

        MPPointF.recycleInstance(iconsOffset);
      }
    }
  }

  // @Override
  public drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[]): void {
    if (!this.mChart) {
      return;
    }
    let waterfallData: WaterfallData | null = this.mChart.getWaterfallData();
    if (!waterfallData) {
      return;
    }

    for (let i = 0; i < indices.length; i++) {
      let high: Highlight = indices[i];
      let set: IWaterfallDataSet | null = waterfallData.getDataSetByIndex(high.getDataSetIndex()) as IWaterfallDataSet;

      if (set == null || !set.isHighlightEnabled())
        continue;

      let e: WaterfallEntry | null = set.getEntryForXValue(high.getX(), high.getY()) as WaterfallEntry;
      if (!e) {
        continue;
      }
      if (!this.isInBoundsX(e, set))
        continue;

      let trans: Transformer | null = this.mChart.getTransformer(set.getAxisDependency());
      let highLightColor: number = set.getHighLightColor();
      if (highLightColor == 0) {
        highLightColor = Color.Black
      }
      this.mHighlightPaint.setColor(highLightColor);
      this.mHighlightPaint.setGlobalAlpha(set.getHighLightAlpha() / 255);

      let y1: number = 0;
      let y2: number = 0;


      y1 = e.getY();
      y2 = e.getMinY();
      if (trans) {
        this.prepareBarHighlight(e.getX(), y1, y2, waterfallData.getBarWidth() / 2, trans);
      }

      this.setHighlightDrawPos(high, this.mBarRect);
      Utils.resetContext2DWithoutFont(c, this.mHighlightPaint);

      let round = this.mBarRect.width() / 2;
      if (this.mBarRect.height() >= this.mBarRect.width()) {

        c.beginPath();
        c.moveTo(this.mBarRect.left + round, this.mBarRect.top);
        c.lineTo(this.mBarRect.right - round, this.mBarRect.top);
        c.arc(this.mBarRect.right - round, this.mBarRect.top + round, round, 3 / 2 * Math.PI, 0);
        c.lineTo(this.mBarRect.right, this.mBarRect.bottom - round);
        c.arc(this.mBarRect.right - round, this.mBarRect.bottom - round, round, 0, Math.PI / 2);
        c.lineTo(this.mBarRect.left + round, this.mBarRect.bottom);
        c.arc(this.mBarRect.left + round, this.mBarRect.bottom - round, round, Math.PI / 2, Math.PI);
        c.lineTo(this.mBarRect.left, this.mBarRect.top + round);
        c.arc(this.mBarRect.left + round, this.mBarRect.top + round, round, Math.PI, 3 / 2 * Math.PI);
        c.closePath();
        c.fill();

      } else {
        this.drawEllipse(c, this.mBarRect.left, this.mBarRect.top, this.mBarRect.right, this.mBarRect.bottom)
      }
    }
  }
}
