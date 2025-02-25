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

import Paint, { DashPathEffect, FontFamily, Style } from '../data/Paint'
import Legend, {
  LegendDirection,
  LegendForm,
  LegendHorizontalAlignment,
  LegendOrientation,
  LegendVerticalAlignment
} from '../components/Legend'
import LegendEntry from '../components/LegendEntry'
import ChartData from '../data/ChartData'
import IBarDataSet from '../interfaces/datasets/IBarDataSet'
import IDataSet from '../interfaces/datasets/IDataSet'
import EntryOhos from '../data/EntryOhos'
import ColorTemplate from '../utils/ColorTemplate'
import FSize from '../utils/FSize'
import Utils from '../utils/Utils'
import ViewPortHandler from '../utils/ViewPortHandler'
import Renderer from './Renderer'
import { JArrayList } from '../utils/JArrayList'
import ICandleDataSet from '../interfaces/datasets/ICandleDataSet'
import IPieDataSet from '../interfaces/datasets/IPieDataSet'
import { LogUtil } from '../utils/LogUtil'
import HashMap from '@ohos.util.HashMap';

export default class LegendRenderer extends Renderer {
  /**
   * paint for the legend labels
   */
  protected mLegendLabelPaint: Paint = new Paint();
  /**
   * paint used for the legend forms
   */
  protected mLegendFormPaint: Paint = new Paint();
  /**
   * the legend object this renderer renders
   */
  protected mLegend: Legend | null = null;
  /**
   * 标签行高
   */
  protected textSizeCache = new HashMap<string, TextMetrics>();

  constructor(viewPortHandler: ViewPortHandler, legend: Legend) {
    super(viewPortHandler);

    this.mLegend = legend;

    this.mLegendLabelPaint = new Paint();
    this.mLegendLabelPaint.setTextSize(Utils.handleDataValues(9));
    this.mLegendLabelPaint.setTextAlign('left');
    this.mLegendLabelPaint.setTextBaseline('bottom');

    this.mLegendFormPaint = new Paint( /*Paint.ANTI_ALIAS_FLAG*/
    );
    this.mLegendFormPaint.setStyle(Style.FILL);
  }

  /**
   * Returns the Paint object used for drawing the Legend labels.
   *
   * @return
   */
  public getLabelPaint(): Paint {
    return this.mLegendLabelPaint;
  }

  /**
   * Returns the Paint object used for drawing the Legend forms.
   *
   * @return
   */
  public getFormPaint(): Paint {
    return this.mLegendFormPaint;
  }


  protected computedEntries: JArrayList<LegendEntry> = new JArrayList<LegendEntry>( /*16*/
  );

  /**
   * Prepares the legend and calculates all needed forms, labels and colors.
   *
   * @param data
   */
  public computeLegend(data ?: ChartData<IDataSet<EntryOhos>>): void {

    if (this.mLegend && !this.mLegend.isLegendCustom() && data) {

      this.computedEntries.clear();

      // loop for building up the colors and labels used in the legend
      for (let i: number = 0; i < data.getDataSetCount(); i++) {

        let dataSet: IDataSet<EntryOhos> | null = data.getDataSetByIndex(i);
        if (dataSet == null) continue;

        let clrs: JArrayList<Number> | null = dataSet.getColors();
        let entryCount: number = dataSet.getEntryCount();

        // if we have a barchart with stacked bars
        if (dataSet.constructor.name == "BarDataSet" && (dataSet as IBarDataSet).isStacked()) {

          let bds: IBarDataSet = dataSet as IBarDataSet;
          let sLabels: string[] = bds.getStackLabels();

          let minEntries: number = Math.min(clrs.size(), bds.getStackSize());

          for (let j: number = 0; j < minEntries; j++) {
            let label: string | null = null;
            if (sLabels.length > 0) {
              let labelIndex: number = j % minEntries;
              label = labelIndex < sLabels.length ? sLabels[labelIndex] : null;
            } else {
              label = null;
            }

            const dashEffect = dataSet.getFormLineDashEffect(); // 使用空对象作为默认值
            this.computedEntries.add(new LegendEntry(
              label,
              dataSet.getForm(),
              dataSet.getFormSize(),
              dataSet.getFormLineWidth(), dashEffect,
              clrs.get(j).valueOf()
            ));
          }

          let label = bds.getLabel();
          if (label != null && label != "") {
            // add the legend description label
            const dashEffect = dataSet.getFormLineDashEffect();
            this.computedEntries.add(new LegendEntry(
              dataSet.getLabel(),
              LegendForm.NONE,
              Number.NaN,
              Number.NaN,
              dashEffect,
              ColorTemplate.COLOR_NONE
            ));
          }

        } else if (dataSet.constructor.name == 'PieDataSet') {
          let pds = dataSet as IPieDataSet;
          for (let j = 0; j < clrs.size() && j < entryCount; j++) {
            this.computedEntries.add(new LegendEntry(
              pds.getEntryForIndex(j).getLabel(),
              dataSet.getForm(),
              dataSet.getFormSize(),
              dataSet.getFormLineWidth(),
              dataSet.getFormLineDashEffect(),
              clrs.get(j).valueOf()
            ));
          }
          let label = pds.getLabel();
          if (label != null && label != "") {
            this.computedEntries.add(new LegendEntry(
              dataSet.getLabel(),
              LegendForm.NONE,
              Number.NaN,
              Number.NaN,
              null,
              ColorTemplate.COLOR_NONE
            ));
          }
        } else if (dataSet.constructor.name == 'CandleDataSet' && (dataSet as ICandleDataSet).getDecreasingColor() != ColorTemplate.COLOR_NONE) {
          let decreasingColor: number = (dataSet as ICandleDataSet).getDecreasingColor();
          let increasingColor: number = (dataSet as ICandleDataSet).getIncreasingColor();

          this.computedEntries.add(new LegendEntry(
            undefined,
            dataSet.getForm(),
            dataSet.getFormSize(),
            dataSet.getFormLineWidth(),
            dataSet.getFormLineDashEffect(),
            decreasingColor
          ))

          this.computedEntries.add(new LegendEntry(
            dataSet.getLabel(),
            dataSet.getForm(),
            dataSet.getFormSize(),
            dataSet.getFormLineWidth(),
            dataSet.getFormLineDashEffect(),
            increasingColor
          ))
        }
        else { // all others

          for (let j: number = 0; j < clrs.size() && j < entryCount; j++) {

            let label: string | undefined = undefined;

            // if multiple colors are set for a DataSet, group them
            if (j < clrs.size() - 1 && j < entryCount - 1) {
              label = undefined;
            } else { // add label to the last entry
              if (!data) {
                label = undefined;
              }
              let dataObj = data.getDataSetByIndex(i);
              if (!dataObj) {
                label = undefined;
              } else {
                label = dataObj.getLabel();
              }
            }
            let clrsData: number = 0;
            if (!clrs) {
              clrsData = 0;
            }
            clrsData = clrs.get(j) as number;
            const dashEffect = dataSet.getFormLineDashEffect(); // 使用空对象作为默认值
            this.computedEntries.add(new LegendEntry(
                label ? label : '',
              dataSet.getForm(),
              dataSet.getFormSize(),
              dataSet.getFormLineWidth(),
              dashEffect,
                clrsData ? clrsData : 0
            ));
          }
        }
      }

      if (this.mLegend && this.mLegend.getExtraEntries() != null) {
        let dataSource: LegendEntry[] | null = this.mLegend.getExtraEntries();
        if (dataSource) {
          for (let i: number = 0; i < dataSource.length; i++) {
            this.computedEntries.add(dataSource[i]);
          }
        }
      }

      if (this.mLegend) {
        this.mLegend.setEntries(this.computedEntries);
        let tf: FontFamily /*Typeface*/
          = this.mLegend.getTypeface();

        if (this.mLegendLabelPaint) {
          if (tf != null) {
            this.mLegendLabelPaint.setFontFamily(tf);
          }
          this.mLegendLabelPaint.setTextSize(this.mLegend.getTextSize());
          this.mLegendLabelPaint.setColor(this.mLegend.getTextColor());
        }

        // calculate all dimensions of the mLegend
        this.mLegend.calculateDimensions(this.mLegendLabelPaint !, this.mViewPortHandler !);
      }
    }
  }

  // protected legendFontMetrics : TextMetrics = new FontMetrics();

  // public void renderLegend(Canvas c) {
  public renderLegend(c: CanvasRenderingContext2D): void {

    if (!this.mLegend || !this.mLegend.isEnabled()) {
      return;
    }

    let tf: FontFamily /*Typeface*/
      = this.mLegend.getTypeface();

    if (!this.mLegendLabelPaint) {
      return;
    }
    if (tf) {
      this.mLegendLabelPaint.setFontFamily(tf);
    }
    this.mLegendLabelPaint.setTextSize(this.mLegend.getTextSize());
    this.mLegendLabelPaint.setColor(this.mLegend.getTextColor());

    // 计算标签行高
    let labelLineHeight: number = Utils.getLabelTextSize(this.mLegendLabelPaint, "Text", this.textSizeCache).height;

    // 计算标签行间距，包括额外的垂直空间
    let labelLineSpacing: number = labelLineHeight * 0.3 + Utils.handleDataValues(this.mLegend.getYEntrySpace());

    // 计算形状偏移以使其与文本垂直居中
    let formYOffset: number = labelLineHeight - labelLineHeight / 2.0;

    // 获取图例条目
    let entries: LegendEntry[] = this.mLegend.getEntries();

    // 获取形状到文本的间距
    let formToTextSpace: number = Utils.handleDataValues(this.mLegend.getFormToTextSpace());

    // 获取水平条目之间的空间
    let xEntrySpace: number = Utils.handleDataValues(this.mLegend.getXEntrySpace());

    // 获取图例方向
    let orientation: LegendOrientation = this.mLegend.getOrientation();

    // 获取图例水平对齐方式
    let horizontalAlignment: LegendHorizontalAlignment = this.mLegend.getHorizontalAlignment();

    // 获取图例垂直对齐方式
    let verticalAlignment: LegendVerticalAlignment = this.mLegend.getVerticalAlignment();

    // 获取图例方向
    let direction: LegendDirection = this.mLegend.getDirection();

    // 获取默认形状的大小
    let defaultFormSize: number = Utils.handleDataValues(this.mLegend.getFormSize());

    // 条目之间的空间
    let stackSpace: number = Utils.handleDataValues(this.mLegend.getStackSpace());

    // 获取垂直偏移量
    let yoffset: number = this.mLegend.getYOffset();

    // 获取水平偏移量
    let xoffset: number = this.mLegend.getXOffset();

    // 设置原点的X坐标
    let originPosX: number = 0.0;


    switch (horizontalAlignment) {
      case LegendHorizontalAlignment.LEFT:

        if (orientation == LegendOrientation.VERTICAL) {
          originPosX = xoffset;
        } else {
          if (this.mViewPortHandler) {
            originPosX = this.mViewPortHandler.contentLeft() + xoffset;
          }
        }
        if (this.mViewPortHandler) {
          LogUtil.log("1. originPosX(" + JSON.stringify(originPosX) + ")= xoffset(" + xoffset + ") + mViewPortHandler.contentLeft(" + this.mViewPortHandler.contentLeft() + ")");
        }

        if (direction == LegendDirection.RIGHT_TO_LEFT)
          originPosX += this.mLegend.mNeededWidth;

        break;

      case LegendHorizontalAlignment.RIGHT:
        if (this.mViewPortHandler) {
          if (orientation == LegendOrientation.VERTICAL)
            originPosX = this.mViewPortHandler.getChartWidth() - xoffset;
          else
            originPosX = this.mViewPortHandler.contentRight() - xoffset;

        }

        if (direction == LegendDirection.LEFT_TO_RIGHT)
          originPosX -= this.mLegend.mNeededWidth;

        break;

      case LegendHorizontalAlignment.CENTER:
        if (this.mViewPortHandler) {
          if (orientation == LegendOrientation.VERTICAL)
            originPosX = this.mViewPortHandler.getChartWidth() / 2.0;
          else
            originPosX = this.mViewPortHandler.contentLeft()
            + this.mViewPortHandler.contentWidth() / 2.0;
        }

        originPosX += (direction == LegendDirection.LEFT_TO_RIGHT
          ? +xoffset
          : -xoffset);

      // Horizontally laid out legends do the center offset on a line basis,
      // So here we offset the vertical ones only.
        if (orientation == LegendOrientation.VERTICAL) {
          originPosX += (direction == LegendDirection.LEFT_TO_RIGHT
            ? -this.mLegend.mNeededWidth / 2.0 + xoffset
            : this.mLegend.mNeededWidth / 2.0 - xoffset);
        }

        break;
    }

    switch (orientation) { // "HORIZONTAL"
      case LegendOrientation.HORIZONTAL: {

        let calculatedLineSizes: JArrayList<FSize> = this.mLegend.getCalculatedLineSizes();
        let calculatedLabelSizes: JArrayList<FSize> = this.mLegend.getCalculatedLabelSizes();
        let calculatedLabelBreakPoints: JArrayList<Boolean> = this.mLegend.getCalculatedLabelBreakPoints();

        let posX: number = originPosX;
        let posY: number = 0.0;

        switch (verticalAlignment) { // "BOTTOM"
          case LegendVerticalAlignment.TOP:
            posY = yoffset;
            LogUtil.log("2.0 posY(" + JSON.stringify(posY) + ")= yoffset(" + yoffset + ")");
            break;

          case LegendVerticalAlignment.BOTTOM:
            if (this.mViewPortHandler) {
              posY = this.mViewPortHandler.getChartHeight() - yoffset - this.mLegend.mNeededHeight;
              LogUtil.log("2.1 posY(" + posY + ")= mViewPortHandler.getChartHeight(" + this.mViewPortHandler.getChartHeight() + ")-mNeededHeight(" + this.mLegend.mNeededHeight + ")-yoffset(" + yoffset + ")");
            }
            break;

          case LegendVerticalAlignment.CENTER:
            if (this.mViewPortHandler) {
              posY = (this.mViewPortHandler.getChartHeight() - this.mLegend.mNeededHeight) / 2.0 + yoffset;
              LogUtil.log("2.1 posY(" + posY + ")= mViewPortHandler.getChartHeight(" + this.mViewPortHandler.getChartHeight() + ")-mNeededHeight/2(" + this.mLegend.mNeededHeight / 2 + ")+yoffset(" + yoffset + ")");
            }
            break;
        }

        let lineIndex: number = 0;
        for (let i: number = 0, count = entries.length; i < count; i++) {
          let e: LegendEntry = entries[i];
          let drawingForm: boolean = e.form != LegendForm.NONE;
          let formSize: number = Number.isNaN(e.formSize) ? defaultFormSize : Utils.handleDataValues(e.formSize);

          if (i < calculatedLabelBreakPoints.size() && calculatedLabelBreakPoints.get(i)) {
            posX = originPosX;
            posY += labelLineHeight + labelLineSpacing;
            LogUtil.log("3.0 i(" + i + ") posX=" + posX + "; posY(" + posY + ")=labelLineHeight(" + labelLineHeight + ")+labelLineSpacing(" + labelLineSpacing + ")");
          }

          if (posX == originPosX &&
          horizontalAlignment == LegendHorizontalAlignment.CENTER && // "LEFT"
          lineIndex < calculatedLineSizes.size()) {
            posX += (direction == LegendDirection.RIGHT_TO_LEFT
              ? calculatedLineSizes.get(lineIndex).width
              : -calculatedLineSizes.get(lineIndex).width) / 2.0;
            lineIndex++;
          }

          let isStacked: boolean = e.label == null; // grouped forms have null labels

          if (drawingForm) {
            if (direction == LegendDirection.RIGHT_TO_LEFT)
              posX -= formSize;
            this.drawForm(c, posX, posY + formYOffset, e, this.mLegend);
            LogUtil.log(`drawForm posX = ${posX}`);

            if (direction == LegendDirection.LEFT_TO_RIGHT) { // "LEFT_TO_RIGHT"
              LogUtil.log("3.2 i(" + i + ") posX(" + posX + ")+=formSize(" + formSize + ")");
              posX += formSize;
            }
          }

          if (!isStacked) {
            if (drawingForm) {
              LogUtil.log("3.3 i(" + i + ") posX(" + posX + ")+=formToTextSpace(" + formToTextSpace + ")");
              posX += direction == LegendDirection.RIGHT_TO_LEFT ? -formToTextSpace :
                formToTextSpace;
            }

            if (direction == LegendDirection.RIGHT_TO_LEFT)
              posX -= calculatedLabelSizes.get(i).width;
            this.drawLabel(c, posX, posY + labelLineHeight, e.label);
            LogUtil.log(`drawLabel posX = ${posX}, e.label = ${e.label}}`);

            if (direction == LegendDirection.LEFT_TO_RIGHT) {
              posX += calculatedLabelSizes.get(i).width;
            }
            LogUtil.log("3.6 i(" + i + ") posX(" + posX + ")+=xEntrySpace(" + xEntrySpace + "); stackSpace(" + stackSpace + ")");
            posX += direction == LegendDirection.RIGHT_TO_LEFT ? -xEntrySpace : xEntrySpace;
          } else
            posX += direction == LegendDirection.RIGHT_TO_LEFT ? -stackSpace : stackSpace;

        }

        break;
      }

      case LegendOrientation.VERTICAL: {
        // contains the stacked legend size in pixels
        let stack: number = 0;
        let wasStacked: boolean = false;
        let posY: number = 0.0;

        switch (verticalAlignment) {
          case LegendVerticalAlignment.TOP:
            posY = (horizontalAlignment == LegendHorizontalAlignment.CENTER
              ? 0.0
              : this.mViewPortHandler ? this.mViewPortHandler.contentTop() : 0);
            posY += yoffset;
            break;

          case LegendVerticalAlignment.BOTTOM:
            posY = (horizontalAlignment == LegendHorizontalAlignment.CENTER
              ? this.mViewPortHandler ? this.mViewPortHandler.getChartHeight() : 0
              : this.mViewPortHandler ? this.mViewPortHandler.contentBottom() : 0);
            posY -= this.mLegend.mNeededHeight + yoffset;
            break;

          case LegendVerticalAlignment.CENTER:
            if (this.mViewPortHandler) {
              posY = this.mViewPortHandler.getChartHeight() / 2.0
              - this.mLegend.mNeededHeight / 2.0
              + this.mLegend.getYOffset();
            }
            break;
        }

        for (let i: number = 0; i < entries.length; i++) {

          let e: LegendEntry = entries[i];
          let drawingForm: boolean = e.form != LegendForm.NONE;
          let formSize: number = Number.isNaN(e.formSize) ? defaultFormSize : Utils.handleDataValues(e.formSize);

          let posX: number = originPosX;

          if (drawingForm) {
            if (direction == LegendDirection.LEFT_TO_RIGHT)
              posX += stack;
            else
              posX -= formSize - stack;

            this.drawForm(c, posX, posY + formYOffset, e, this.mLegend);

            if (direction == LegendDirection.LEFT_TO_RIGHT)
              posX += formSize;
          }

          if (e.label != null && e.label != "") {

            if (drawingForm && !wasStacked)
              posX += direction == LegendDirection.LEFT_TO_RIGHT ? formToTextSpace
                : -formToTextSpace;
            else if (wasStacked)
              posX = originPosX;

            if (direction == LegendDirection.RIGHT_TO_LEFT) {
              posX -= Utils.getLabelTextSize(this.mLegendLabelPaint, e.label, this.textSizeCache).width;
            }

            if (!wasStacked) {
              this.drawLabel(c, posX, posY + labelLineHeight, e.label);
            } else {
              posY += labelLineHeight + labelLineSpacing;
              this.drawLabel(c, posX, posY + labelLineHeight, e.label);
            }

            // make a step down
            posY += labelLineHeight + labelLineSpacing;
            stack = 0;
          } else {
            stack += formSize + stackSpace;
            wasStacked = true;
          }
        }

        break;

      }
    }
  }

  // private mLineFormPath:Path2D = new Path2D();
  /**
   * Draws the Legend-form at the given position with the color at the given
   * index.
   *
   * @param c      canvas to draw with
   * @param x      position
   * @param y      position
   * @param entry  the entry to render
   * @param legend the legend context
   */
  protected drawForm(
    c: CanvasRenderingContext2D,
    x: number, y: number,
    entry: LegendEntry,
    legend: Legend): void {

    if (entry.formColor == ColorTemplate.COLOR_SKIP ||
    entry.formColor == ColorTemplate.COLOR_NONE ||
    entry.formColor == 0)
      return;
    let form: LegendForm = entry.form;
    if (form == LegendForm.DEFAULT)
      form = legend.getForm();

    this.mLegendFormPaint.setColor(entry.formColor);
    let formSize: number = Utils.handleDataValues(
      Number.isNaN(entry.formSize)
        ? legend.getFormSize()
        : entry.formSize);
    let half: number = formSize / 2;

    switch (form) {

      case LegendForm.DEFAULT:
      case LegendForm.CIRCLE:
        this.mLegendFormPaint.setStyle(Style.FILL);
        c.fillStyle = this.mLegendFormPaint.fillStyle;
        c.beginPath();
        c.arc(x + half, y, half, 0, 2 * Math.PI);
        c.closePath();
        c.fill();
        break;

      case LegendForm.SQUARE:
        this.mLegendFormPaint.setStyle(Style.FILL);
        c.fillStyle = this.mLegendFormPaint.fillStyle;
        c.fillRect(x, y - half, formSize, 2 * half)
        break;

      case LegendForm.LINE: {
        let formLineWidth: number = Utils.handleDataValues(
          Number.isNaN(entry.formLineWidth)
            ? legend.getFormLineWidth()
            : entry.formLineWidth);
        let formLineDashEffect: DashPathEffect | null = entry.formLineDashEffect == null
          ? legend.getFormLineDashEffect()
          : entry.formLineDashEffect;
        this.mLegendFormPaint.setStyle(Style.STROKE)
        this.mLegendFormPaint.setStrokeWidth(formLineWidth);
        this.mLegendFormPaint.setDashPathEffect(formLineDashEffect !);

        Utils.resetContext2DWithoutFont(c, this.mLegendFormPaint);
        c.beginPath();
        c.moveTo(x, y);
        c.lineTo(x + formSize, y);
        c.stroke();
        c.closePath();
      }
        break;
      case LegendForm.NONE:
      case LegendForm.EMPTY:
      default:
        break;
    }
  }

  /**
   * Draws the provided label at the given position.
   *
   * @param c      to draw with
   * @param x
   * @param y
   * @param label the label to draw
   */
  // protected void drawLabel(Canvas c, float x, float y, String label) {
  protected drawLabel(c: CanvasRenderingContext2D, x: number, y: number, label: string): void {
    LogUtil.log("-------------------sLabels drawLabel: " + label)
    Utils.resetContext2DWithoutLine(c, this.mLegendLabelPaint)
    c.fillText(label, x, y)
  }
}
