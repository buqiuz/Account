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

import BarLineScatterCandleBubbleData from '../data/BarLineScatterCandleBubbleData';
import IBarLineScatterCandleBubbleDataSet from '../interfaces/datasets/IBarLineScatterCandleBubbleDataSet';
import BarLineChartTouchListener from '../listener/BarLineChartTouchListener';
import Chart from './ChartModel';
import BarLineScatterCandleBubbleDataProvider from '../interfaces/dataprovider/BarLineScatterCandleBubbleDataProvider';
import Paint, { Style } from '../data/Paint';
import OnDrawListener from '../listener/OnDrawListener';
import YAxis, { AxisDependency } from '../components/YAxis';
import { XAxisPosition } from '../components/XAxis';
import YAxisRenderer from '../renderer/YAxisRenderer';
import XAxisRenderer from '../renderer/XAxisRenderer';
import Transformer from '../utils/Transformer';
import ChartHighlighter from '../highlight/ChartHighlighter';
import MyRect from '../data/Rect';
import { LegendHorizontalAlignment, LegendOrientation, LegendVerticalAlignment } from '../components/Legend';
import Utils, { LongPressType, PanActionType, PinchActionType } from '../utils/Utils';
import Matrix from '../utils/Matrix';
import MPPointF from '../utils/MPPointF';
import MPPointD from '../utils/MPPointD';
import EntryOhos from '../data/EntryOhos';
import Highlight from '../highlight/Highlight';
import ChartTouchListener from '../listener/ChartTouchListener';
import IDataSet from '../interfaces/datasets/IDataSet';
import ChartData from '../data/ChartData';
import ViewPortHandler from '../utils/ViewPortHandler';
import MoveViewJob from '../jobs/MoveViewJob';
import { EventControl, EventType } from '../listener/EventControl';
import { LogUtil } from '../utils/LogUtil';
import HashMap from '@ohos.util.HashMap';
import CanvasUtil from '../utils/CanvasUtil';

/**
 * Base-class of LineChart, BarChart, ScatterChart and CandleStickChart.
 *
 *
 */
export default abstract class BarLineChartBaseModel<T extends BarLineScatterCandleBubbleData<IBarLineScatterCandleBubbleDataSet<EntryOhos>>>
extends Chart<T> implements BarLineScatterCandleBubbleDataProvider {
  /**
   * the maximum number of entries to which values will be drawn
   * (entry numbers greater than this value will cause value-labels to disappear)
   */
  protected mMaxVisibleCount: number = 100;
  /**
   * flag that indicates if auto scaling on the y axis is enabled
   */
  protected mAutoScaleMinMaxEnabled: boolean = false;
  /**
   * flag that indicates if pinch-zoom is enabled. if true, both x and y axis
   * can be scaled with 2 fingers, if false, x and y axis can be scaled
   * separately
   */
  protected mPinchZoomEnabled: boolean = false;
  /**
   * flag that indicates if double tap zoom is enabled or not
   */
  protected mDoubleTapToZoomEnabled: boolean = true;
  /**
   * flag that indicates if highlighting per dragging over a fully zoomed out
   * chart is enabled
   */
  protected mHighlightPerDragEnabled: boolean = true;
  /**
   * if true, dragging is enabled for the chart
   */
  private mDragXEnabled: boolean = true;
  private mDragYEnabled: boolean = true;
  private mScaleXEnabled: boolean = true;
  private mScaleYEnabled: boolean = true;
  /**
   * paint object for the (by default) lightgrey background of the grid
   */
  protected mGridBackgroundPaint: Paint | null = null;
  protected mBorderPaint: Paint | null = null;
  /**
   * flag indicating if the grid background should be drawn or not
   */
  protected mDrawGridBackground: boolean = false;
  protected mDrawBorders: boolean = false;
  protected mClipValuesToContent: boolean = false;
  protected mClipDataToContent: boolean = true;
  /**
   * Sets the minimum offset (padding) around the chart, defaults to 15
   */
  protected mMinOffset: number = 15.0;
  /**
   * flag indicating if the chart should stay at the same position after a rotation. Default is false.
   */
  protected mKeepPositionOnRotation: boolean = false;
  /**
   * the listener for user drawing on the chart
   */
  protected mDrawListener: OnDrawListener | null = null;
  /**
   * the object representing the labels on the left y-axis
   */
  protected mAxisLeft: YAxis | null = null;
  /**
   * the object representing the labels on the right y-axis
   */
  protected mAxisRight: YAxis | null = null;
  protected mLeftAxisTransformer: Transformer | null = null;
  protected mRightAxisTransformer: Transformer | null = null;
  protected mAxisRendererLeft: YAxisRenderer | null = null;
  protected mAxisRendererRight: YAxisRenderer | null = null;
  protected mXAxisRenderer: XAxisRenderer | null = null;
  private mEventControl: EventControl = new EventControl();

  /**
   * long press cursor response capability
   */
  protected mLongPressCursorEnabled: boolean = false;
  protected mLongPressDuration: number = 500;
  protected mSwipeEnabled: boolean = false;


  //Represents whether the chart is horizontally flipped.
  protected isHorizontalFlip: boolean = false;
  textSizeCache = new HashMap<string, TextMetrics>();
  /**

   Set the horizontal flip status of the element.
   @param isHorizontalFlip - Boolean value indicating whether to horizontally flip the element.
   */
  public setHorizontalFlip(isHorizontalFlip: boolean): void {
    this.isHorizontalFlip = isHorizontalFlip;
  }
  /**

   Get the current horizontal flip status of the element.
   @returns boolean - Returns true if the element is horizontally flipped, false otherwise.
   */
  public getHorizontalFlip(): boolean {
    return this.isHorizontalFlip;
  }

  public setLongPressCursorEnabled(enabled: boolean): void {
    this.mLongPressCursorEnabled = enabled;
  }

  public getLongPressCursorEnabled(): boolean {
    return this.mLongPressCursorEnabled;
  }

  public setLongPressDuration(duration: number): void {
    this.mLongPressDuration = duration;
  }

  public getLongPressDuration(): number {
    return this.mLongPressDuration;
  }

  public setSwipeEnabled(enabled: boolean): void {
    this.mSwipeEnabled = enabled;
  }

  public getSwipeEnabled(): boolean {
    return this.mSwipeEnabled;
  }

  public get eventControl() {
    return this.mEventControl
  }

  // /** the approximator object used for data filtering */
  // private Approximator mApproximator;
  constructor() {
    super();
    this.init();
  }

  protected mYAxisExtensionLine: boolean = false;

  public setYAxisExtensionLine(opt: boolean) {
    this.mYAxisExtensionLine = opt;
  }

  public yAxisExtensionLineIsEnable() {
    return this.mYAxisExtensionLine
  }

  /*public BarLineChartBase(Context context, AttributeSet attrs, int defStyle) {
      super(context, attrs, defStyle);
  }

  public BarLineChartBase(Context context, AttributeSet attrs) {
      super(context, attrs);
  }

  public BarLineChartBase(Context context) {
      super(context);
  }*/
  //
  protected init(): void {
    super.init();

    this.mAxisLeft = new YAxis(AxisDependency.LEFT);
    this.mAxisRight = new YAxis(AxisDependency.RIGHT);

    this.mLeftAxisTransformer = new Transformer(this.mViewPortHandler);
    this.mRightAxisTransformer = new Transformer(this.mViewPortHandler);

    this.mAxisRendererLeft = new YAxisRenderer(this.mViewPortHandler, this.mAxisLeft, this.mLeftAxisTransformer);
    this.mAxisRendererRight = new YAxisRenderer(this.mViewPortHandler, this.mAxisRight, this.mRightAxisTransformer);

    if (this.mXAxis) {
      this.mXAxisRenderer = new XAxisRenderer(this.mViewPortHandler, this.mXAxis, this.mLeftAxisTransformer);
    }

    this.setHighlighter(new ChartHighlighter(this));

    this.mChartTouchListener = new BarLineChartTouchListener(this, this.mViewPortHandler.getMatrixTouch(), 3) as ChartTouchListener<Chart<ChartData<IDataSet<EntryOhos>>>>;

    this.mGridBackgroundPaint = new Paint();
    this.mGridBackgroundPaint.setStyle(Style.FILL);
    // mGridBackgroundPaint.setColor(Color.WHITE);
    this.mGridBackgroundPaint.setColor('#f0f0f0'); // light
    // grey

    this.mBorderPaint = new Paint();
    this.mBorderPaint.setStyle(Style.STROKE);
    this.mBorderPaint.setColor(Color.Black);
    this.mBorderPaint.setStrokeWidth(Utils.handleDataValues(1));
  }

  // for performance tracking
  private totalTime: number = 0;
  private drawCycles: number = 0;

  public onDraw(context2D: CanvasRenderingContext2D): void {
    super.onDraw(context2D);

    if (!this.mData || !this.mRenderer || !this.mChartSizeCorrected)
      return;

    // 清空画布，防止图表堆叠
    CanvasUtil.clearCanvas(context2D);
    // let starttime: number = new Date().getMilliseconds();

    // execute all drawing commands
    this.drawGridBackground(context2D);

    if (this.mAutoScaleMinMaxEnabled) {
      this.autoScale();
    }

    if (this.mAxisRendererLeft && this.mAxisLeft && this.mAxisLeft.isEnabled()) {
      this.mAxisRendererLeft.computeAxis(this.mAxisLeft.mAxisMinimum, this.mAxisLeft.mAxisMaximum, this.mAxisLeft.isInverted());
    }

    if (this.mAxisRendererRight && this.mAxisRight && this.mAxisRight.isEnabled()) {
      this.mAxisRendererRight.computeAxis(this.mAxisRight.mAxisMinimum, this.mAxisRight.mAxisMaximum, this.mAxisRight.isInverted());
    }

    if (this.mXAxisRenderer && this.mXAxis && this.mXAxis.isEnabled()) {
      this.mXAxisRenderer.computeAxis(this.mXAxis.mAxisMinimum, this.mXAxis.mAxisMaximum, false);
    }

    // y轴延长线计算
    let extraLength = 0;
    if (this.yAxisExtensionLineIsEnable()) {
      extraLength = this.mAxisLeft?.isEnabled() ? this.calcExtensionLine(this.mAxisRendererLeft) : 0;
      if (!extraLength) {
        extraLength = this.mAxisRight?.isEnabled() ? this.calcExtensionLine(this.mAxisRendererRight) : 0;
      }
    }

    if (this.mXAxisRenderer) {
      this.mXAxisRenderer.renderAxisLine(context2D);
    }
    if (this.mAxisRendererLeft) {
      this.mAxisRendererLeft.renderAxisLine(context2D, extraLength);
    }
    if (this.mAxisRendererRight) {
      this.mAxisRendererRight.renderAxisLine(context2D, extraLength);
    }

    if (this.mXAxisRenderer && this.mXAxis && this.mXAxis.isDrawGridLinesBehindDataEnabled()) {
      this.mXAxisRenderer.renderGridLines(context2D);
    }

    if (this.mAxisRendererLeft && this.mAxisLeft && this.mAxisLeft.isDrawGridLinesBehindDataEnabled()) {
      this.mAxisRendererLeft.renderGridLines(context2D);
    }

    if (this.mAxisRendererRight && this.mAxisRight && this.mAxisRight.isDrawGridLinesBehindDataEnabled()) {
      this.mAxisRendererRight.renderGridLines(context2D);
    }

    if (this.mXAxisRenderer && this.mXAxis && this.mXAxis.isEnabled()) {
      this.mXAxisRenderer.renderCustomGridLines(context2D);
      this.mXAxis.isDrawLimitLinesBehindDataEnabled() &&
      this.mXAxisRenderer.renderLimitLines(context2D);
    }

    if (this.mAxisRendererLeft && this.mAxisLeft && this.mAxisLeft.isEnabled()) {
      this.mAxisRendererLeft.renderCustomGridLines(context2D);
      this.mAxisLeft.isDrawLimitLinesBehindDataEnabled() &&
      this.mAxisRendererLeft.renderLimitLines(context2D, this.getHorizontalFlip());
    }

    if (this.mAxisRendererRight && this.mAxisRight && this.mAxisRight.isEnabled()) {
      this.mAxisRendererRight.renderCustomGridLines(context2D);
      this.mAxisRight.isDrawLimitLinesBehindDataEnabled() &&
      this.mAxisRendererRight.renderLimitLines(context2D, this.getHorizontalFlip());
    }

    //let clipRestoreCount:number =
    context2D.save();

    if (this.isClipDataToContentEnabled()) {
      // make sure the data cannot be drawn outside the content-rect
      let rect = this.mViewPortHandler.getContentRect();
      context2D.beginPath();
      context2D.rect(rect.left, rect.top, rect.width(), rect.height());
      context2D.closePath();
      context2D.clip();
    }

    this.mRenderer.drawData(context2D);

    if (this.mXAxisRenderer && this.mXAxis && !this.mXAxis.isDrawGridLinesBehindDataEnabled()) {
      this.mXAxisRenderer.renderGridLines(context2D);
    }

    if (this.mAxisRendererLeft && this.mAxisLeft && !this.mAxisLeft.isDrawGridLinesBehindDataEnabled()) {
      this.mAxisRendererLeft.renderGridLines(context2D);
    }

    if (this.mAxisRendererRight && this.mAxisRight && !this.mAxisRight.isDrawGridLinesBehindDataEnabled()) {
      this.mAxisRendererRight.renderGridLines(context2D);
    }

    // if highlighting is enabled
    if (this.valuesToHighlight() && this.mIndicesToHighlight)
      this.mRenderer.drawHighlighted(context2D, this.mIndicesToHighlight, false);

    // Removes clipping rectangle
    context2D.restore();

    if (this.mRenderer) {
      this.mRenderer.drawExtras(context2D);
    }

    if (this.mXAxisRenderer && this.mXAxis && this.mXAxis.isEnabled() && !this.mXAxis.isDrawLimitLinesBehindDataEnabled()) {
      this.mXAxisRenderer.renderLimitLines(context2D);
    }

    if (this.mAxisRendererLeft && this.mAxisLeft && this.mAxisLeft.isEnabled() && !this.mAxisLeft.isDrawLimitLinesBehindDataEnabled()) {
      this.mAxisRendererLeft.renderLimitLines(context2D, this.getHorizontalFlip());
    }

    if (this.mAxisRendererRight && this.mAxisRight && this.mAxisRight.isEnabled() && !this.mAxisRight.isDrawLimitLinesBehindDataEnabled()) {
      this.mAxisRendererRight.renderLimitLines(context2D, this.getHorizontalFlip());
    }

    if (this.mXAxisRenderer) {
      this.mXAxisRenderer.renderAxisLabels(context2D, this.getHorizontalFlip());
    }
    if (this.mAxisRendererLeft) {
      this.mAxisRendererLeft.renderAxisLabels(context2D, this.getHorizontalFlip(), true);
    }
    if (this.mAxisRendererRight) {
      this.mAxisRendererRight.renderAxisLabels(context2D, this.getHorizontalFlip(), false);
    }

    if (this.isClipValuesToContentEnabled()) {
      // this.clipRestoreCount =
      context2D.save();
      let rect = this.mViewPortHandler.getContentRect()
      context2D.rect(rect.left, rect.right, rect.width(), rect.height());
      context2D.clip();
      this.mRenderer.drawValues(context2D, this.getHorizontalFlip());
      context2D.restore();
      //canvas.restoreToCount(clipRestoreCount);
    } else {
      this.mRenderer.drawValues(context2D, this.getHorizontalFlip());
    }

    if (this.mLegendRenderer) {
      this.mLegendRenderer.renderLegend(context2D);
    }

    this.drawDescription(context2D);

    this.drawMarkers(context2D);

    this.drawLongPressMarkers(context2D);

    // if (this.mLogEnabled) {
    //   let drawtime: number = (new Date().getMilliseconds() - starttime);
    //   this.totalTime += drawtime;
    //   this.drawCycles += 1;
    //   let average: number = this.totalTime / this.drawCycles;
    //   LogUtil.log(Chart.LOG_TAG + "Drawtime: " + drawtime + " ms, average: " + average + " ms, cycles: "
    //     + this.drawCycles);
    // }
  }

  // y轴计算延长线
  private calcExtensionLine(render: YAxisRenderer | null) {
    let extensionLength = 0;
    if (render) {
      if (this.mXAxis) {
        extensionLength = this.mXAxis.getYOffset() +
          this.mXAxis.mLabelRotatedHeight / 2 +
        Utils.getLabelTextSize(render.getPaintAxisLine(), '0', this.textSizeCache).height;
      }
    }
    return extensionLength;
  }

  /**
   * RESET PERFORMANCE TRACKING FIELDS
   */
  public resetTracking(): void {
    this.totalTime = 0;
    this.drawCycles = 0;
  }

  protected prepareValuePxMatrix(): void {

    if (this.mLogEnabled && this.mXAxis) {
      LogUtil.log(Chart.LOG_TAG + "Preparing Value-Px Matrix, xmin: " + this.mXAxis.mAxisMinimum + ", xmax: "
        + this.mXAxis.mAxisMaximum + ", xdelta: " + this.mXAxis.mAxisRange);
    }

    if (this.mRightAxisTransformer && this.mXAxis && this.mAxisRight) {
      this.mRightAxisTransformer.prepareMatrixValuePx(this.mXAxis.mAxisMinimum,
        this.mXAxis.mAxisRange,
        this.mAxisRight.mAxisRange,
        this.mAxisRight.mAxisMinimum);
    }
    if (this.mLeftAxisTransformer && this.mXAxis && this.mAxisLeft) {
      this.mLeftAxisTransformer.prepareMatrixValuePx(this.mXAxis.mAxisMinimum,
        this.mXAxis.mAxisRange,
        this.mAxisLeft.mAxisRange,
        this.mAxisLeft.mAxisMinimum);
    }
  }

  protected prepareOffsetMatrix(): void {
    if (this.mRightAxisTransformer && this.mAxisRight) {
      this.mRightAxisTransformer.prepareMatrixOffset(this.mAxisRight.isInverted());
    }
    if (this.mLeftAxisTransformer && this.mAxisLeft) {
      this.mLeftAxisTransformer.prepareMatrixOffset(this.mAxisLeft.isInverted());
    }
  }

  public notifyDataSetChanged(): void {

    if (this.mData == null) {
      if (this.mLogEnabled)
        LogUtil.log(Chart.LOG_TAG + "Preparing... DATA NOT SET.");
      return;
    } else {
      if (this.mLogEnabled)
        LogUtil.log(Chart.LOG_TAG + "Preparing...");
    }

    if (this.mRenderer != null)
      this.mRenderer.initBuffers();

    this.calcMinMax();

    if (this.mAxisRendererLeft && this.mAxisLeft) {
      this.mAxisRendererLeft.computeAxis(this.mAxisLeft.mAxisMinimum, this.mAxisLeft.mAxisMaximum, this.mAxisLeft.isInverted());
    }
    if (this.mAxisRendererRight && this.mAxisRight) {
      this.mAxisRendererRight.computeAxis(this.mAxisRight.mAxisMinimum, this.mAxisRight.mAxisMaximum, this.mAxisRight.isInverted());
    }
    if (this.mXAxisRenderer && this.mXAxis) {
      this.mXAxisRenderer.computeAxis(this.mXAxis.mAxisMinimum, this.mXAxis.mAxisMaximum, false);
    }


    if (this.mLegendRenderer && this.mLegend) {
      this.mLegendRenderer.computeLegend(this.mData);
    }

    this.calculateOffsets();
  }

  /**
   * Performs auto scaling of the axis by recalculating the minimum and maximum y-values based on the entries currently in view.
   */
  protected autoScale(): void {
    if (!this.mData) {
      return;
    }
    const fromX: number = this.getLowestVisibleX();
    const toX: number = this.getHighestVisibleX();

    this.mData.calcMinMaxY(fromX, toX);
    if (this.mXAxis) {
      this.mXAxis.calculate(this.mData.getXMin(), this.mData.getXMax());
    }

    // calculate axis range (min / max) according to provided data

    if (this.mAxisLeft && this.mAxisLeft.isEnabled())
      this.mAxisLeft.calculate(this.mData.getYMin(AxisDependency.LEFT),
        this.mData.getYMax(AxisDependency.LEFT));

    if (this.mAxisRight && this.mAxisRight.isEnabled())
      this.mAxisRight.calculate(this.mData.getYMin(AxisDependency.RIGHT),
        this.mData.getYMax(AxisDependency.RIGHT));

    this.calculateOffsets();
  }

  protected calcMinMax(): void {
    if (!this.mData) {
      return;
    }
    if (this.mXAxis) {
      this.mXAxis.calculate(this.mData.getXMin(), this.mData.getXMax());
    }

    // calculate axis range (min / max) according to provided data
    if (this.mAxisLeft) {
      this.mAxisLeft.calculate(this.mData.getYMin(AxisDependency.LEFT), this.mData.getYMax(AxisDependency.LEFT));
    }
    if (this.mAxisRight) {
      this.mAxisRight.calculate(this.mData.getYMin(AxisDependency.RIGHT), this.mData.getYMax(AxisDependency
        .RIGHT));
    }
  }

  protected calculateLegendOffsets(offsets: MyRect): void {

    offsets.left = 0;
    offsets.right = 0;
    offsets.top = 0;
    offsets.bottom = 0;

    if (this.mLegend == null || !this.mLegend.isEnabled() || this.mLegend.isDrawInsideEnabled())
      return;

    switch (this.mLegend.getOrientation()) {
      case LegendOrientation.VERTICAL:

        switch (this.mLegend.getHorizontalAlignment()) {
          case LegendHorizontalAlignment.LEFT:
            offsets.left += Math.min(this.mLegend.mNeededWidth,
              this.mViewPortHandler.getChartWidth() * this.mLegend.getMaxSizePercent())
              + this.mLegend.getXOffset();
            break;

          case LegendHorizontalAlignment.RIGHT:
            offsets.right += Math.min(this.mLegend.mNeededWidth,
              this.mViewPortHandler.getChartWidth() * this.mLegend.getMaxSizePercent())
              + this.mLegend.getXOffset();
            break;

          case LegendHorizontalAlignment.CENTER:

            switch (this.mLegend.getVerticalAlignment()) {
              case LegendVerticalAlignment.TOP:
                offsets.top += Math.min(this.mLegend.mNeededHeight,
                  this.mViewPortHandler.getChartHeight() * this.mLegend.getMaxSizePercent())
                  + this.mLegend.getYOffset();
                break;

              case LegendVerticalAlignment.BOTTOM:
                offsets.bottom += Math.min(this.mLegend.mNeededHeight,
                  this.mViewPortHandler.getChartHeight() * this.mLegend.getMaxSizePercent())
                  + this.mLegend.getYOffset();
                break;

              default:
                break;
            }
        }

        break;

      case LegendOrientation.HORIZONTAL:

        switch (this.mLegend.getVerticalAlignment()) {
          case LegendVerticalAlignment.TOP:
            offsets.top += Math.min(this.mLegend.mNeededHeight,
              this.mViewPortHandler.getChartHeight() * this.mLegend.getMaxSizePercent())
              + this.mLegend.getYOffset();


            break;

          case LegendVerticalAlignment.BOTTOM:
            offsets.bottom += Math.min(this.mLegend.mNeededHeight,
              this.mViewPortHandler.getChartHeight() * this.mLegend.getMaxSizePercent())
              + this.mLegend.getYOffset();


            break;

          default:
            break;
        }
        break;
    }
  }

  protected mOffsetsBuffer: MyRect = new MyRect();

  public calculateOffsets(): void {

    if (!this.mCustomViewPortEnabled) {

      let offsetLeft: number = 0;
      let offsetRight: number = 0;
      let offsetTop: number = 0;
      let offsetBottom: number = 0;

      this.calculateLegendOffsets(this.mOffsetsBuffer);

      offsetLeft += this.mOffsetsBuffer.left;
      offsetTop += this.mOffsetsBuffer.top;
      offsetRight += this.mOffsetsBuffer.right;
      offsetBottom += this.mOffsetsBuffer.bottom;

      // offsets for y-labels
      if (this.mAxisLeft && this.mAxisRendererLeft && this.mAxisLeft.needsOffset()) {

        // Y轴边距：最长的Y轴标签宽度 + 2倍的 XOffset
        offsetLeft += this.mAxisLeft.getRequiredWidthSpace(this.mAxisRendererLeft.getPaintAxisLabels());
      }

      if (this.mAxisRight && this.mAxisRendererRight && this.mAxisRight.needsOffset()) {
        offsetRight += this.mAxisRight.getRequiredWidthSpace(this.mAxisRendererRight.getPaintAxisLabels());
      }

      if (this.mXAxis && this.mXAxis.isEnabled() && this.mXAxis.isDrawLabelsEnabled()) {

        // 标签旋转的高度 + yOffset
        let xLabelHeight: number = this.mXAxis.mLabelRotatedHeight + this.mXAxis.getYOffset();

        // offsets for x-labels
        if (this.mXAxis.getPosition() == XAxisPosition.BOTTOM) {

          offsetBottom += xLabelHeight;

        } else if (this.mXAxis.getPosition() == XAxisPosition.TOP) {

          offsetTop += xLabelHeight;

        } else if (this.mXAxis.getPosition() == XAxisPosition.BOTH_SIDED) {

          offsetBottom += xLabelHeight;
          offsetTop += xLabelHeight;
        }
      }

      offsetTop += this.getExtraTopOffset();
      offsetRight += this.getExtraRightOffset();
      offsetBottom += this.getExtraBottomOffset();
      offsetLeft += this.getExtraLeftOffset();

      let minOffset: number = Utils.handleDataValues(this.mMinOffset);

      this.mViewPortHandler.restrainViewPort(
        Math.max(minOffset, offsetLeft),
        Math.max(minOffset, offsetTop),
        Math.max(minOffset, offsetRight),
        Math.max(minOffset, offsetBottom));

      if (this.mLogEnabled) {
        LogUtil.log(Chart.LOG_TAG + "offsetLeft: " + offsetLeft + ", offsetTop: " + offsetTop
          + ", offsetRight: " + offsetRight + ", offsetBottom: " + offsetBottom);
        LogUtil.log(Chart.LOG_TAG + "Content: " + this.mViewPortHandler.getContentRect().toString());
      }
    }

    this.prepareOffsetMatrix();
    this.prepareValuePxMatrix();
  }

  /**
   * draws the grid background
   */
  protected drawGridBackground(c: CanvasRenderingContext2D): void {
    if (this.mDrawGridBackground) {
      if (this.mGridBackgroundPaint) {
        Utils.resetContext2DWithoutFont(c, this.mGridBackgroundPaint);
      }

      c.beginPath();
      let rect = this.mViewPortHandler.getContentRect();
      c.rect(rect.left, rect.top, rect.width(), rect.height());
      c.fill()
      c.closePath();
      // let recPaint:RectPaint=new RectPaint(this.mGridBackgroundPaint as RectPaint);
      // recPaint.setStartPoint([this.mViewPortHandler.getContentRect().left,this.mViewPortHandler.getContentRect().right])
      // recPaint.setWidth(this.mViewPortHandler.getContentRect().width());
      // recPaint.setHeight(this.mViewPortHandler.getContentRect().height());
      // // draw the grid background
      // //c.drawRect(mViewPortHandler.getContentRect(), mGridBackgroundPaint);
      // return recPaint
    }
    if (this.mDrawBorders) {
      if (this.mBorderPaint) {
        Utils.resetContext2DWithoutFont(c, this.mBorderPaint);
      }

      c.beginPath();
      let rect = this.mViewPortHandler.getContentRect();
      c.rect(rect.left, rect.top, rect.width(), rect.height());
      c.stroke()
      c.closePath();
      //  let recPaint: RectPaint=new RectPaint(this.mBorderPaint as RectPaint);
      //  recPaint.setStartPoint([this.mViewPortHandler.getContentRect().left,this.mViewPortHandler.getContentRect().right])
      //  recPaint.setWidth(this.mViewPortHandler.getContentRect().width());
      //  recPaint.setHeight(this.mViewPortHandler.getContentRect().height());
      // //c.drawRect(mViewPortHandler.getContentRect(), mBorderPaint);
      //   return recPaint
    }
  }

  /**
   * Returns the Transformer class that contains all matrices and is
   * responsible for transforming values into pixels on the screen and
   * backwards.
   *
   * @return
   */
  public getTransformer(which: AxisDependency): Transformer | null {
    if (which == AxisDependency.LEFT)
      return this.mLeftAxisTransformer;
    else
      return this.mRightAxisTransformer;
  }

  public onTouchEvent(event: TouchEvent): void {
    if (event.touches.length >= 2) {
      return;
    }
    // check if touch gestures are enabled
    if (!this.mTouchEnabled) {
      return;
    }
    if (this.eventControl.eventIsDisable(EventType.SingleTap)) {
      return;
    }
    if (this.mChartTouchListener == null || this.mData == null)
      return;

    switch (event.type) {
      case TouchType.Down:
        this.mChartTouchListener.actionDown(true, event);
        break;
      case TouchType.Move:
        this.mChartTouchListener.actionMove(true, event);
        break;
      case TouchType.Up:
        this.mChartTouchListener.actionUp(true, event);
        break;
      default:
        break;
    }
  }

  public onSingleTapUp(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void {
    if (!this.mTouchEnabled) {
      return;
    }
    if (this.eventControl.eventIsDisable(EventType.SingleTap)) {
      return;
    }
    if (this.mChartTouchListener) {
      this.mChartTouchListener.onSingleTapUp(isTouchEvent, event);
    }
  }

  public onDoubleTap(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void {
    if (!this.mTouchEnabled) {
      return;
    }
    if (this.eventControl.eventIsDisable(EventType.DoubleTap)) {
      return;
    }
    if (this.mChartTouchListener) {
      this.mChartTouchListener.onDoubleTap(isTouchEvent, event);
    }
  }

  public onLongPress(isTouchEvent: boolean, actionType: LongPressType, event: TouchEvent | GestureEvent): void {
    if (!this.mTouchEnabled) {
      return;
    }
    if (this.eventControl.eventIsDisable(EventType.LongPress)) {
      return;
    }
    if (this.mChartTouchListener) {
      switch (actionType) {
        case 'Down':
          this.mChartTouchListener.onLongPressed(isTouchEvent, event);
          break;
        case 'Up':
          this.mChartTouchListener.onLongPressUp(isTouchEvent, event);
          break;
        case 'Cancel':
          this.mChartTouchListener.onLongPressCancel(isTouchEvent, event);
          break;
        default:
          this.mChartTouchListener.onLongPressed(isTouchEvent, event);
          break;
      }
    }
  }

  public calcPos(isTouchEvent: boolean, event: TouchEvent | GestureEvent) {
    return (this?.mChartTouchListener as BarLineChartTouchListener).getXyByEvent(isTouchEvent, event);
  }

  public onPinch(isTouchEvent: boolean, actionType: PinchActionType, event: TouchEvent | GestureEvent): void {
    if (!this.mTouchEnabled) {
      return;
    }
    if (this.mChartTouchListener) {
      switch (actionType) {
        case 'Start':
          this.mChartTouchListener.actionPinchDown(isTouchEvent, event);
          break;
        case 'Update':
          this.mChartTouchListener.actionMove(isTouchEvent, event);
          break;
        case 'End':
          this.mChartTouchListener.actionPinchUp(isTouchEvent, event);
          break;
        case 'Cancel':
        default:
          this.mChartTouchListener.actionCancel(isTouchEvent, event);
          break
      }
    }
  }

  public computeScroll(event: GestureEvent): void {

    if (this.mChartTouchListener instanceof BarLineChartTouchListener)
      (this.mChartTouchListener as BarLineChartTouchListener).computeScroll(event);
  }

  /**
   * ################ ################ ################ ################
   */
  /**
   * CODE BELOW THIS RELATED TO SCALING AND GESTURES AND MODIFICATION OF THE
   * VIEWPORT
   */

  protected mZoomMatrixBuffer: Matrix = new Matrix();

  /**
   * Zooms in by 1.4f, into the charts center.
   */
  public zoomIn(): void {

    let center: MPPointF = this.mViewPortHandler.getContentCenter();

    this.mViewPortHandler.zoomIn(center.x, -center.y, this.mZoomMatrixBuffer);
    this.mViewPortHandler.refresh(this.mZoomMatrixBuffer, this, false);

    MPPointF.recycleInstance(center);

    // Range might have changed, which means that Y-axis labels
    // could have changed in size, affecting Y-axis size.
    // So we need to recalculate offsets.
    this.calculateOffsets();
    this.invalidate();
  }

  /**
   * Zooms out by 0.7f, from the charts center.
   */
  public zoomOut(): void {

    let center: MPPointF = this.mViewPortHandler.getContentCenter();

    this.mViewPortHandler.zoomOut(center.x, -center.y, this.mZoomMatrixBuffer);
    this.mViewPortHandler.refresh(this.mZoomMatrixBuffer, this, false);

    MPPointF.recycleInstance(center);

    // Range might have changed, which means that Y-axis labels
    // could have changed in size, affecting Y-axis size.
    // So we need to recalculate offsets.
    this.calculateOffsets();
    this.invalidate();
  }

  /**
   * Zooms out to original size.
   */
  public resetZoom(): void {

    this.mViewPortHandler.resetZoom(this.mZoomMatrixBuffer);
    this.mViewPortHandler.refresh(this.mZoomMatrixBuffer, this, false);

    // Range might have changed, which means that Y-axis labels
    // could have changed in size, affecting Y-axis size.
    // So we need to recalculate offsets.
    this.calculateOffsets();
    this.invalidate();
  }

  /**
   * Zooms in or out by the given scale factor. x and y are the coordinates
   * (in pixels) of the zoom center.
   *
   * @param scaleX if < 1f --> zoom out, if > 1f --> zoom in
   * @param scaleY if < 1f --> zoom out, if > 1f --> zoom in
   * @param x
   * @param y
   */
  /* public zoom(scaleX:number, scaleY:number, x:number,y:number):void {

       this.mViewPortHandler.zoom(scaleX, scaleY, x, -y, this.mZoomMatrixBuffer);
       this.mViewPortHandler.refresh(this.mZoomMatrixBuffer, this, false);

       // Range might have changed, which means that Y-axis labels
       // could have changed in size, affecting Y-axis size.
       // So we need to recalculate offsets.
       this.calculateOffsets();
       //this.postInvalidate();
   }*/

  /**
   * Zooms in or out by the given scale factor.
   * x and y are the values (NOT PIXELS) of the zoom center..
   *
   * @param scaleX
   * @param scaleY
   * @param xValue
   * @param yValue
   * @param axis   the axis relative to which the zoom should take place
   */
  public zoom(scaleX: number, scaleY: number, xValue: number, yValue: number, axis?: AxisDependency): void {
    if (axis == null || axis == undefined) {
      this.mViewPortHandler.zoom(scaleX, scaleY, xValue, -yValue, this.mZoomMatrixBuffer);
      this.mViewPortHandler.refresh(this.mZoomMatrixBuffer, this, false);

      // Range might have changed, which means that Y-axis labels
      // could have changed in size, affecting Y-axis size.
      // So we need to recalculate offsets.
      this.calculateOffsets();
      this.invalidate();
    } else {
      // let job:Runnable= ZoomJob.getInstance(this.mViewPortHandler, scaleX, scaleY, xValue, yValue,this.getTransformer(axis),axis, this);
      // this.addViewportJob(job);
    }
  }

  /**
   * Zooms to the center of the chart with the given scale factor.
   *
   * @param scaleX
   * @param scaleY
   */
  public zoomToCenter(scaleX: number, scaleY: number): void {

    let center: MPPointF | null = this.getCenterOffsets();
    let save: Matrix = this.mZoomMatrixBuffer;
    if (center) {
      this.mViewPortHandler.zoom(scaleX, scaleY, center.x, -center.y, save);
      this.mViewPortHandler.refresh(save, this, false);
    }
  }

  /**
   * Zooms by the specified scale factor to the specified values on the specified axis.
   *
   * @param scaleX
   * @param scaleY
   * @param xValue
   * @param yValue
   * @param axis
   * @param duration
   */
  public zoomAndCenterAnimated(scaleX: number, scaleY: number, xValue: number, yValue: number, axis: AxisDependency,
                               duration: number): void {

    let origin: MPPointD = this.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentTop(), axis);

    // let job:Runnable= AnimatedZoomJob.getInstance(this.mViewPortHandler, this, this.getTransformer(axis), this.getAxis(axis), this.mXAxis
    //                 .mAxisRange, scaleX, scaleY, this.mViewPortHandler.getScaleX(), this.mViewPortHandler.getScaleY(),
    //         xValue, yValue, origin.x, origin.y, duration);
    // this.addViewportJob(job);
    MPPointD.recycleInstance(origin);
  }

  protected mFitScreenMatrixBuffer: Matrix = new Matrix();

  /**
   * Resets all zooming and dragging and makes the chart fit exactly it's
   * bounds.
   */
  public fitScreen(): void {
    let save: Matrix = this.mFitScreenMatrixBuffer;
    this.mViewPortHandler.fitScreen(save);
    this.mViewPortHandler.refresh(save, this, false);
    this.calculateOffsets();
    this.invalidate();
  }

  /**
   * Sets the minimum scale factor value to which can be zoomed out. 1f =
   * fitScreen
   *
   * @param scaleX
   * @param scaleY
   */
  public setScaleMinima(scaleX: number, scaleY: number): void {
    this.mViewPortHandler.setMinimumScaleX(scaleX);
    this.mViewPortHandler.setMinimumScaleY(scaleY);
  }

  /**
   * Sets the size of the area (range on the x-axis) that should be maximum
   * visible at once (no further zooming out allowed). If this is e.g. set to
   * 10, no more than a range of 10 on the x-axis can be viewed at once without
   * scrolling.
   *
   * @param maxXRange The maximum visible range of x-values.
   */
  public setVisibleXRangeMaximum(maxXRange: number): void {
    let xScale: number = 1;
    if (this.mXAxis) {
      xScale = this.mXAxis.mAxisRange / (maxXRange);
    }
    this.mViewPortHandler.setMinimumScaleX(xScale);
  }

  /**
   * Sets the size of the area (range on the x-axis) that should be minimum
   * visible at once (no further zooming in allowed). If this is e.g. set to
   * 10, no less than a range of 10 on the x-axis can be viewed at once without
   * scrolling.
   *
   * @param minXRange The minimum visible range of x-values.
   */
  public setVisibleXRangeMinimum(minXRange: number): void {
    let xScale: number = 1;
    if (this.mXAxis) {
      xScale = this.mXAxis.mAxisRange / (minXRange);
    }
    this.mViewPortHandler.setMaximumScaleX(xScale);
  }

  /**
   * Limits the maximum and minimum x range that can be visible by pinching and zooming. e.g. minRange=10, maxRange=100 the
   * smallest range to be displayed at once is 10, and no more than a range of 100 values can be viewed at once without
   * scrolling
   *
   * @param minXRange
   * @param maxXRange
   */
  public setVisibleXRange(minXRange: number, maxXRange: number): void {
    let minScale: number = 1;
    if (this.mXAxis) {
      minScale = this.mXAxis.mAxisRange / minXRange;
    }
    let maxScale: number = 1;
    if (this.mXAxis) {
      maxScale = this.mXAxis.mAxisRange / maxXRange;
    }
    this.mViewPortHandler.setMinMaxScaleX(minScale, maxScale);
  }

  /**
   * Sets the size of the area (range on the y-axis) that should be maximum
   * visible at once.
   *
   * @param maxYRange the maximum visible range on the y-axis
   * @param axis      the axis for which this limit should apply
   */
  public setVisibleYRangeMaximum(maxYRange: number, axis: AxisDependency): void {
    let yScale: number = this.getAxisRange(axis) / maxYRange;
    this.mViewPortHandler.setMinimumScaleY(yScale);
  }

  /**
   * Sets the size of the area (range on the y-axis) that should be minimum visible at once, no further zooming in possible.
   *
   * @param minYRange
   * @param axis      the axis for which this limit should apply
   */
  public setVisibleYRangeMinimum(minYRange: number, axis: AxisDependency): void {
    let yScale: number = this.getAxisRange(axis) / minYRange;
    this.mViewPortHandler.setMaximumScaleY(yScale);
  }

  /**
   * Limits the maximum and minimum y range that can be visible by pinching and zooming.
   *
   * @param minYRange
   * @param maxYRange
   * @param axis
   */
  public setVisibleYRange(minYRange: number, maxYRange: number, axis: AxisDependency): void {
    let minScale: number = this.getAxisRange(axis) / minYRange;
    let maxScale: number = this.getAxisRange(axis) / maxYRange;
    this.mViewPortHandler.setMinMaxScaleY(minScale, maxScale);
  }


  /**
   * Moves the left side of the current viewport to the specified x-position.
   * This also refreshes the chart by calling invalidate().
   *
   * @param xValue
   */
  public moveViewToX(xValue: number): void {

    if (this.mViewPortHandler) {
      let transformer: Transformer | null = this.getTransformer(AxisDependency.LEFT)
      if (transformer) {
        let job: MoveViewJob = MoveViewJob.getInstance(this.mViewPortHandler, xValue, 0, transformer, this);
        this.addViewportJob(job);
      }
    }
  }

  /**
   * This will move the left side of the current viewport to the specified
   * x-value on the x-axis, and center the viewport to the specified y value on the y-axis.
   * This also refreshes the chart by calling invalidate().
   *
   * @param xValue
   * @param yValue
   * @param axis   - which axis should be used as a reference for the y-axis
   */
  public moveViewTo(xValue: number, yValue: number, axis: AxisDependency): void {

    let yInView: number = this.getAxisRange(axis) / this.mViewPortHandler.getScaleY();

    const transformer = this.getTransformer(axis);
    if (transformer) {
      let job: MoveViewJob = MoveViewJob.getInstance(this.mViewPortHandler, xValue, yValue + yInView / 2,
        transformer, this);
      this.addViewportJob(job);
    }
  }

  /**
   * This will move the left side of the current viewport to the specified x-value
   * and center the viewport to the y value animated.
   * This also refreshes the chart by calling invalidate().
   *
   * @param xValue
   * @param yValue
   * @param axis
   * @param duration the duration of the animation in milliseconds
   */
  public moveViewToAnimated(xValue: number, yValue: number, axis: AxisDependency, duration: number): void {

    let bounds: MPPointD = this.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentTop(), axis);

    let yInView: number = this.getAxisRange(axis) / this.mViewPortHandler.getScaleY();
    // let job:Runnable = AnimatedMoveViewJob.getInstance(this.mViewPortHandler, xValue, yValue + yInView / 2,
    //         this.getTransformer(axis), this, bounds.x, bounds.y, duration);

    // this.addViewportJob(job);

    MPPointD.recycleInstance(bounds);
  }

  /**
   * Centers the viewport to the specified y value on the y-axis.
   * This also refreshes the chart by calling invalidate().
   *
   * @param yValue
   * @param axis   - which axis should be used as a reference for the y-axis
   */
  public centerViewToY(yValue: number, axis: AxisDependency): void {

    let valsInView: number = this.getAxisRange(axis) / this.mViewPortHandler.getScaleY();

    const transformer = this.getTransformer(axis);
    if (transformer) {
      let job: MoveViewJob = MoveViewJob.getInstance(this.mViewPortHandler, 0, yValue + valsInView / 2,
        transformer, this);
      this.addViewportJob(job);
    }
  }

  /**
   * This will move the center of the current viewport to the specified
   * x and y value.
   * This also refreshes the chart by calling invalidate().
   *
   * @param xValue
   * @param yValue
   * @param axis   - which axis should be used as a reference for the y axis
   */
  public centerViewTo(xValue: number, yValue: number, axis: AxisDependency): void {

    const xAxis = this.getXAxis();
    const transformer = this.getTransformer(axis)
    if (xAxis && transformer) {
      let yInView: number = this.getAxisRange(axis) / this.mViewPortHandler.getScaleY();
      let xInView: number = xAxis.mAxisRange / this.mViewPortHandler.getScaleX();

      let job: MoveViewJob = MoveViewJob.getInstance(this.mViewPortHandler,
        xValue - xInView / 2, yValue + yInView / 2,
        transformer, this);

      this.addViewportJob(job);
    }
  }

  /**
   * This will move the center of the current viewport to the specified
   * x and y value animated.
   *
   * @param xValue
   * @param yValue
   * @param axis
   * @param duration the duration of the animation in milliseconds
   */
  public centerViewToAnimated(xValue: number, yValue: number, axis: AxisDependency, duration: number): void {

    let bounds: MPPointD = this.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentTop(), axis);

    // let yInView:number= this.getAxisRange(axis) / this.mViewPortHandler.getScaleY();
    // let xInView:number =this.getXAxis().mAxisRange /this.mViewPortHandler.getScaleX();

    // let job:Runnable = AnimatedMoveViewJob.getInstance(this.mViewPortHandler,
    //         xValue - xInView / 2, yValue + yInView / 2,
    //         this.getTransformer(axis), this, bounds.x, bounds.y, duration);

    // this.addViewportJob(job);

    MPPointD.recycleInstance(bounds);
  }

  /**
   * flag that indicates if a custom viewport offset has been set
   */
  private mCustomViewPortEnabled: boolean = false;

  /**
   * Sets custom offsets for the current ViewPort (the offsets on the sides of
   * the actual chart window). Setting this will prevent the chart from
   * automatically calculating it's offsets. Use resetViewPortOffsets() to
   * undo this. ONLY USE THIS WHEN YOU KNOW WHAT YOU ARE DOING, else use
   * setExtraOffsets(...).
   *
   * @param left
   * @param top
   * @param right
   * @param bottom
   */
  public setViewPortOffsets(left: number, top: number, right: number, bottom: number): void {

    this.mCustomViewPortEnabled = true;
    // let view=this;
    // this.post(new Runnable('setViewPortOffsets',()=>{
    this.mViewPortHandler.restrainViewPort(left, top, right, bottom);
    this.prepareOffsetMatrix();
    this.prepareValuePxMatrix();
    // }))
  }

  /**
   * Resets all custom offsets set via setViewPortOffsets(...) method. Allows
   * the chart to again calculate all offsets automatically.
   */
  public resetViewPortOffsets(): void {
    this.mCustomViewPortEnabled = false;
    this.calculateOffsets();
  }

  /**
   * ################ ################ ################ ################
   */
  /** CODE BELOW IS GETTERS AND SETTERS */

  /**
   * Returns the range of the specified axis.
   *
   * @param axis
   * @return
   */
  protected getAxisRange(axis: AxisDependency): number {
    if (axis == AxisDependency.LEFT) {
      if (this.mAxisLeft) {
        return this.mAxisLeft.mAxisRange;
      } else {
        return 0;
      }
    } else {
      if (this.mAxisRight) {
        return this.mAxisRight.mAxisRange;
      } else {
        return 0;
      }
    }
  }

  /**
   * Sets the OnDrawListener
   *
   * @param drawListener
   */
  public setOnDrawListener(drawListener: OnDrawListener): void {
    this.mDrawListener = drawListener;
  }

  /**
   * Gets the OnDrawListener. May be null.
   *
   * @return
   */
  public getDrawListener(): OnDrawListener | null {
    return this.mDrawListener;
  }

  protected mGetPositionBuffer: number[] = new Array(2);

  /**
   * Returns a recyclable MPPointF instance.
   * Returns the position (in pixels) the provided Entry has inside the chart
   * view or null, if the provided Entry is null.
   *
   * @param e
   * @return
   */
  public getPosition(e: EntryOhos, axis: AxisDependency): MPPointF {

    // if (e == null)
    //     return null;

    this.mGetPositionBuffer[0] = e.getX();
    this.mGetPositionBuffer[1] = e.getY();

    let transformer: Transformer | null = this.getTransformer(axis)
    if (transformer) {
      transformer.pointValuesToPixel(this.mGetPositionBuffer);
    }
    return MPPointF.getInstance(this.mGetPositionBuffer[0], this.mGetPositionBuffer[1]);
  }

  /**
   * sets the number of maximum visible drawn values on the chart only active
   * when setDrawValues() is enabled
   *
   * @param count
   */
  public setMaxVisibleValueCount(count: number): void {
    this.mMaxVisibleCount = count;
  }

  public getMaxVisibleCount(): number {
    return this.mMaxVisibleCount;
  }

  /**
   * Set this to true to allow highlighting per dragging over the chart
   * surface when it is fully zoomed out. Default: true
   *
   * @param enabled
   */
  public setHighlightPerDragEnabled(enabled: boolean): void {
    this.mHighlightPerDragEnabled = enabled;
  }

  public isHighlightPerDragEnabled(): boolean {
    return this.mHighlightPerDragEnabled;
  }

  /**
   * Sets the color for the background of the chart-drawing area (everything
   * behind the grid lines).
   *
   * @param color
   */
  public setGridBackgroundColor(color: string | number | CanvasGradient | CanvasPattern): void {
    if (this.mGridBackgroundPaint) {
      this.mGridBackgroundPaint.setColor(color);
    }
  }

  /**
   * Set this to true to enable dragging (moving the chart with the finger)
   * for the chart (this does not effect scaling).
   *
   * @param enabled
   */
  public setDragEnabled(enabled: boolean): void {
    this.mDragXEnabled = enabled;
    this.mDragYEnabled = enabled;
  }

  /**
   * Returns true if dragging is enabled for the chart, false if not.
   *
   * @return
   */
  public isDragEnabled(): boolean {
    return this.mDragXEnabled || this.mDragYEnabled;
  }

  /**
   * Set this to true to enable dragging on the X axis
   *
   * @param enabled
   */
  public setDragXEnabled(enabled: boolean): void {
    this.mDragXEnabled = enabled;
  }

  /**
   * Returns true if dragging on the X axis is enabled for the chart, false if not.
   *
   * @return
   */
  public isDragXEnabled(): boolean {
    return this.mDragXEnabled;
  }

  /**
   * Set this to true to enable dragging on the Y axis
   *
   * @param enabled
   */
  public setDragYEnabled(enabled: boolean): void {
    this.mDragYEnabled = enabled;
  }

  /**
   * Returns true if dragging on the Y axis is enabled for the chart, false if not.
   *
   * @return
   */
  public isDragYEnabled(): boolean {
    return this.mDragYEnabled;
  }

  /**
   * Set this to true to enable scaling (zooming in and out by gesture) for
   * the chart (this does not effect dragging) on both X- and Y-Axis.
   *
   * @param enabled
   */
  public setScaleEnabled(enabled: boolean): void {
    this.mScaleXEnabled = enabled;
    this.mScaleYEnabled = enabled;
  }

  public setScaleXEnabled(enabled: boolean): void {
    this.mScaleXEnabled = enabled;
  }

  public setScaleYEnabled(enabled: boolean): void {
    this.mScaleYEnabled = enabled;
  }

  public isScaleXEnabled(): boolean {
    return this.mScaleXEnabled;
  }

  public isScaleYEnabled(): boolean {
    return this.mScaleYEnabled;
  }

  /**
   * Set this to true to enable zooming in by double-tap on the chart.
   * Default: enabled
   *
   * @param enabled
   */
  public setDoubleTapToZoomEnabled(enabled: boolean): void {
    this.mDoubleTapToZoomEnabled = enabled;
  }

  /**
   * Returns true if zooming via double-tap is enabled false if not.
   *
   * @return
   */
  public isDoubleTapToZoomEnabled(): boolean {
    return this.mDoubleTapToZoomEnabled;
  }

  /**
   * set this to true to draw the grid background, false if not
   *
   * @param enabled
   */
  public setDrawGridBackground(enabled: boolean): void {
    this.mDrawGridBackground = enabled;
  }

  /**
   * When enabled, the borders rectangle will be rendered.
   * If this is enabled, there is no point drawing the axis-lines of x- and y-axis.
   *
   * @param enabled
   */
  public setDrawBorders(enabled: boolean): void {
    this.mDrawBorders = enabled;
  }

  /**
   * When enabled, the borders rectangle will be rendered.
   * If this is enabled, there is no point drawing the axis-lines of x- and y-axis.
   *
   * @return
   */
  public isDrawBordersEnabled(): boolean {
    return this.mDrawBorders;
  }

  /**
   * When enabled, the values will be clipped to contentRect,
   * otherwise they can bleed outside the content rect.
   *
   * @param enabled
   */
  public setClipValuesToContent(enabled: boolean): void {
    this.mClipValuesToContent = enabled;
  }

  /**
   * When disabled, the data and/or highlights will not be clipped to contentRect. Disabling this option can
   *   be useful, when the data lies fully within the content rect, but is drawn in such a way (such as thick lines)
   *   that there is unwanted clipping.
   *
   * @param enabled
   */
  public setClipDataToContent(enabled: boolean): void {
    this.mClipDataToContent = enabled;
  }

  /**
   * When enabled, the values will be clipped to contentRect,
   * otherwise they can bleed outside the content rect.
   *
   * @return
   */
  public isClipValuesToContentEnabled(): boolean {
    return this.mClipValuesToContent;
  }

  /**
   * When disabled, the data and/or highlights will not be clipped to contentRect. Disabling this option can
   *   be useful, when the data lies fully within the content rect, but is drawn in such a way (such as thick lines)
   *   that there is unwanted clipping.
   *
   * @return
   */
  public isClipDataToContentEnabled(): boolean {
    return this.mClipDataToContent;
  }

  /**
   * Sets the width of the border lines in vp.
   *
   * @param width
   */
  public setBorderWidth(width: number): void {
    if (this.mBorderPaint) {
      this.mBorderPaint.setStrokeWidth(Utils.handleDataValues(width));
    }
  }

  /**
   * Sets the color of the chart border lines.
   *
   * @param color
   */
  public setBorderColor(color: number): void {
    if (this.mBorderPaint) {
      this.mBorderPaint.setColor(color);
    }
  }

  /**
   * Gets the minimum offset (padding) around the chart, defaults to 15.f
   */
  public getMinOffset(): number {
    return this.mMinOffset;
  }

  /**
   * Sets the minimum offset (padding) around the chart, defaults to 15.f
   */
  public setMinOffset(minOffset: number): void {
    this.mMinOffset = minOffset;
  }

  /**
   * Returns true if keeping the position on rotation is enabled and false if not.
   */
  public isKeepPositionOnRotation(): boolean {
    return this.mKeepPositionOnRotation;
  }

  /**
   * Sets whether the chart should keep its position (zoom / scroll) after a rotation (orientation change)
   */
  public setKeepPositionOnRotation(keepPositionOnRotation: boolean): void {
    this.mKeepPositionOnRotation = keepPositionOnRotation;
  }

  /**
   * Returns a recyclable MPPointD instance
   * Returns the x and y values in the chart at the given touch point
   * (encapsulated in a MPPointD). This method transforms pixel coordinates to
   * coordinates / values in the chart. This is the opposite method to
   * getPixelForValues(...).
   *
   * @param x
   * @param y
   * @return
   */
  public getValuesByTouchPoint(x: number, y: number, axis: AxisDependency, outputPoint?: MPPointD): MPPointD {
    let transformer: Transformer | null = this.getTransformer(axis);
    if (!transformer) {
      transformer = new Transformer(new ViewPortHandler());
    }
    return transformer.getValuesByTouchPoint(x, y, (outputPoint == null || outputPoint == undefined) ? MPPointD.getInstance(0, 0) : outputPoint);
  }

  /**
   * Returns a recyclable MPPointD instance
   * Transforms the given chart values into pixels. This is the opposite
   * method to getValuesByTouchPoint(...).
   *
   * @param x
   * @param y
   * @return
   */
  public getPixelForValues(x: number, y: number, axis: AxisDependency): MPPointD {
    let transformer: Transformer | null = this.getTransformer(axis);
    if (!transformer) {
      transformer = new Transformer(new ViewPortHandler());
    }
    return transformer.getPixelForValues(x, y);
  }

  /**
   * returns the Entry object displayed at the touched position of the chart
   *
   * @param x
   * @param y
   * @return
   */
  public getEntryByTouchPoint(x: number, y: number): EntryOhos | null {
    let h: Highlight | null = this.getHighlightByTouchPoint(x, y);
    if (h != null && this.mData) {
      return this.mData.getEntryForHighlight(h);
    }
    return null;
  }

  /**
   * returns the DataSet object displayed at the touched position of the chart
   *
   * @param x
   * @param y
   * @return
   */
  public getDataSetByTouchPoint(x: number, y: number): IBarLineScatterCandleBubbleDataSet<EntryOhos> | null {
    let h: Highlight | null = this.getHighlightByTouchPoint(x, y);
    if (h != null && this.mData) {
      return this.mData.getDataSetByIndex(h.getDataSetIndex()) as IBarLineScatterCandleBubbleDataSet<EntryOhos>;
    }
    return null;
  }

  /**
   * buffer for storing lowest visible x point
   */
  protected posForGetLowestVisibleX: MPPointD = MPPointD.getInstance(0, 0);

  /**
   * Returns the lowest x-index (value on the x-axis) that is still visible on
   * the chart.
   *
   * @return
   */
  public getLowestVisibleX(): number {
    let transformer: Transformer | null = this.getTransformer(AxisDependency.LEFT);
    if (transformer) {
      transformer.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(),
        this.mViewPortHandler.contentBottom(), this.posForGetLowestVisibleX);
    }
    let result: number = this.posForGetLowestVisibleX.x;
    if (this.mXAxis) {
      result = Math.max(this.mXAxis.mAxisMinimum, this.posForGetLowestVisibleX.x);
    }
    return result;
  }

  /**
   * buffer for storing highest visible x point
   */
  protected posForGetHighestVisibleX: MPPointD = MPPointD.getInstance(0, 0);

  /**
   * Returns the highest x-index (value on the x-axis) that is still visible
   * on the chart.
   *
   * @return
   */
  public getHighestVisibleX(): number {
    let transformer: Transformer | null = this.getTransformer(AxisDependency.LEFT);
    if (transformer) {
      transformer.getValuesByTouchPoint(this.mViewPortHandler.contentRight(),
        this.mViewPortHandler.contentBottom(), this.posForGetHighestVisibleX);
    }

    let result: number = this.posForGetHighestVisibleX.x;
    if (this.mXAxis) {
      result = Math.min(this.mXAxis.mAxisMaximum, this.posForGetHighestVisibleX.x);
    }
    return result;
  }

  /**
   * Returns the range visible on the x-axis.
   *
   * @return
   */
  public getVisibleXRange(): number {
    return Math.abs(this.getHighestVisibleX() - this.getLowestVisibleX());
  }

  /**
   * returns the current x-scale factor
   */
  public getScaleX(): number {
    if (this.mViewPortHandler == null)
      return 1;
    else
      return this.mViewPortHandler.getScaleX();
  }

  /**
   * returns the current y-scale factor
   */
  public getScaleY(): number {
    if (this.mViewPortHandler == null)
      return 1;
    else
      return this.mViewPortHandler.getScaleY();
  }

  /**
   * if the chart is fully zoomed out, return true
   *
   * @return
   */
  public isFullyZoomedOut(): boolean {
    return this.mViewPortHandler.isFullyZoomedOut();
  }

  /**
   * Returns the left y-axis object. In the horizontal bar-chart, this is the
   * top axis.
   *
   * @return
   */
  public getAxisLeft(): YAxis | null {
    return this.mAxisLeft;
  }

  /**
   * Returns the right y-axis object. In the horizontal bar-chart, this is the
   * bottom axis.
   *
   * @return
   */
  public getAxisRight(): YAxis | null {
    return this.mAxisRight;
  }

  /**
   * Returns the y-axis object to the corresponding AxisDependency. In the
   * horizontal bar-chart, LEFT == top, RIGHT == BOTTOM
   *
   * @param axis
   * @return
   */
  public getAxis(axis: AxisDependency): YAxis | null {
    if (axis == AxisDependency.LEFT)
      return this.mAxisLeft;
    else
      return this.mAxisRight;
  }

  public isInverted(axis: AxisDependency): boolean {
    let axisObj = this.getAxis(axis);
    if (axisObj) {
      return axisObj.isInverted();
    }
    return false;
  }

  /**
   * If set to true, both x and y axis can be scaled simultaneously with 2 fingers, if false,
   * x and y axis can be scaled separately. default: false
   *
   * @param enabled
   */
  public setPinchZoom(enabled: boolean): void {
    this.mPinchZoomEnabled = enabled;
  }

  /**
   * returns true if pinch-zoom is enabled, false if not
   *
   * @return
   */
  public isPinchZoomEnabled(): boolean {
    return this.mPinchZoomEnabled;
  }

  /**
   * Set an offset in vp that allows the user to drag the chart over it's
   * bounds on the x-axis.
   *
   * @param offset
   */
  public setDragOffsetX(offset: number): void {
    this.mViewPortHandler.setDragOffsetX(offset);
  }

  /**
   * Set an offset in vp that allows the user to drag the chart over it's
   * bounds on the y-axis.
   *
   * @param offset
   */
  public setDragOffsetY(offset: number): void {
    this.mViewPortHandler.setDragOffsetY(offset);
  }

  /**
   * Returns true if both drag offsets (x and y) are zero or smaller.
   *
   * @return
   */
  public hasNoDragOffset(): boolean {
    return this.mViewPortHandler.hasNoDragOffset();
  }

  public getRendererXAxis(): XAxisRenderer | null {
    return this.mXAxisRenderer;
  }

  /**
   * Sets a custom XAxisRenderer and overrides the existing (default) one.
   *
   * @param xAxisRenderer
   */
  public setXAxisRenderer(xAxisRenderer: XAxisRenderer): void {
    this.mXAxisRenderer = xAxisRenderer;
  }

  public getRendererLeftYAxis(): YAxisRenderer | null {
    return this.mAxisRendererLeft;
  }

  /**
   * Sets a custom axis renderer for the left axis and overwrites the existing one.
   *
   * @param rendererLeftYAxis
   */
  public setRendererLeftYAxis(rendererLeftYAxis: YAxisRenderer): void {
    this.mAxisRendererLeft = rendererLeftYAxis;
  }

  public getRendererRightYAxis(): YAxisRenderer | null {
    return this.mAxisRendererRight;
  }

  /**
   * Sets a custom axis renderer for the right acis and overwrites the existing one.
   *
   * @param rendererRightYAxis
   */
  public setRendererRightYAxis(rendererRightYAxis: YAxisRenderer): void {
    this.mAxisRendererRight = rendererRightYAxis;
  }

  public getYChartMax(): number {
    if (this.mAxisLeft && this.mAxisRight) {
      return Math.max(this.mAxisLeft.mAxisMaximum, this.mAxisRight.mAxisMaximum);
    }
    return 0;
  }

  public getYChartMin(): number {
    if (this.mAxisLeft && this.mAxisRight) {
      return Math.min(this.mAxisLeft.mAxisMinimum, this.mAxisRight.mAxisMinimum);
    }
    return 0;
  }

  /**
   * Returns true if either the left or the right or both axes are inverted.
   *
   * @return
   */
  public isAnyAxisInverted(): boolean {
    if (this.mAxisLeft && this.mAxisLeft.isInverted()) {
      return true;
    }
    if (this.mAxisRight && this.mAxisRight.isInverted()) {
      return true;
    }
    return false;
  }

  /**
   * Flag that indicates if auto scaling on the y axis is enabled. This is
   * especially interesting for charts displaying financial data.
   *
   * @param enabled the y axis automatically adjusts to the min and max y
   *                values of the current x axis range whenever the viewport
   *                changes
   */
  public setAutoScaleMinMaxEnabled(enabled: boolean): void {
    this.mAutoScaleMinMaxEnabled = enabled;
  }

  /**
   * @return true if auto scaling on the y axis is enabled.
   * @default false
   */
  public isAutoScaleMinMaxEnabled(): boolean {
    return this.mAutoScaleMinMaxEnabled;
  }

  public setPaint(p: Paint, which: number): void {
    super.setPaint(p, which);
    switch (which) {
      case Chart.PAINT_GRID_BACKGROUND:
        this.mGridBackgroundPaint = p;
        break;
    }
  }

  public getPaint(which: number): Paint | null {
    let p: Paint | null = super.getPaint(which);
    if (p != null)
      return p;

    switch (which) {
      case Chart.PAINT_GRID_BACKGROUND:
        return this.mGridBackgroundPaint;
    }

    return null;
  }

  public mOnSizeChangedBuffer: number[] = new Array(2);

  public onSizeChanged(w: number, h: number, oldw: number, oldh: number): void {

    // Saving current position of chart.
    this.mOnSizeChangedBuffer[0] = this.mOnSizeChangedBuffer[1] = 0;

    if (this.mKeepPositionOnRotation) {
      this.mOnSizeChangedBuffer[0] = this.mViewPortHandler.contentLeft();
      this.mOnSizeChangedBuffer[1] = this.mViewPortHandler.contentTop();
      let transformer: Transformer | null = this.getTransformer(AxisDependency.LEFT);
      if (transformer) {
        transformer.pixelsToValue(this.mOnSizeChangedBuffer);
      }
    }

    //Superclass transforms chart.
    super.onSizeChanged(w, h, oldw, oldh);

    if (this.mKeepPositionOnRotation) {

      //Restoring old position of chart.
      let transformer: Transformer | null = this.getTransformer(AxisDependency.LEFT);
      if (transformer) {
        transformer.pointValuesToPixel(this.mOnSizeChangedBuffer);
      }
      this.mViewPortHandler.centerViewPort(this.mOnSizeChangedBuffer, this);
    } else {
      this.mViewPortHandler.refresh(this.mViewPortHandler.getMatrixTouch(), this, true);
    }
  }

  getWidth(): number {
    return this.width
  };

  getHeight(): number {
    return this.height
  };
}
