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

import ChartHighlighter from '../highlight/ChartHighlighter';
import MyRect from '../data/Rect';
import Highlight from '../highlight/Highlight';
import ChartAnimator from '../animation/ChartAnimator';
import ViewPortHandler from '../utils/ViewPortHandler';
import LegendRenderer from '../renderer/LegendRenderer';
import Legend from '../components/Legend';
import Description from '../components/Description';
import { XAxis } from '../components/XAxis';
import Paint, { FontFamily } from '../data/Paint';
import DefaultValueFormatter from '../formatter/DefaultValueFormatter';
import IDataSet from '../interfaces/datasets/IDataSet';
import EntryOhos from '../data/EntryOhos';
import OnChartValueSelectedListener from '../listener/OnChartValueSelectedListener';
import ChartTouchListener from '../listener/ChartTouchListener';
import OnChartGestureListener from '../listener/OnChartGestureListener';
import DataRenderer from '../renderer/DataRenderer';
import IHighlighter from '../highlight/IHighlighter';
import Utils from '../utils/Utils';
import { ChartColor } from '../utils/ColorTemplate';
import MPPointF from '../utils/MPPointF';
import IMarker from '../components/IMarker';
import IValueFormatter from '../formatter/IValueFormatter';
import ChartData from '../data/ChartData';
import BarLineScatterCandleBubbleDataProvider from '../interfaces/dataprovider/BarLineScatterCandleBubbleDataProvider';
import ChartInterface from '../interfaces/dataprovider/ChartInterface';
import AnimatorUpdateListener from '../listener/AnimatorUpdateListener';
import { AnimatorResult } from '@ohos.animator';
import { LogUtil } from '../utils/LogUtil';
import { JArrayList } from '../utils/JArrayList';
import MoveViewJob from '../jobs/MoveViewJob';
import GCUtil from '../utils/GCUtils';
import CanvasUtil from '../utils/CanvasUtil';

/**
 * Baseclass of all Chart-Views.
 *
 *
 */
interface DispatchEvent {
  type: string;
  timeStamp: number;
}

export enum LastGesture {
  NONE, SINGLE_TAP, LONG_PRESS
}

export default abstract class ChartModel<T extends ChartData<IDataSet<EntryOhos>>> implements ChartInterface, AnimatorUpdateListener {
  public mJobs: JArrayList<MoveViewJob> = new JArrayList<MoveViewJob>();
  public static LOG_TAG: string = "mpchart: ";
  /**
   * flag that indicates if logging is enabled or not
   */
  protected mLogEnabled: boolean = false;
  /**
   * object that holds all data that was originally set for the chart, before
   * it was modified or any filtering algorithms had been applied
   */
  protected mData: T | null = null;
  /**
   * Flag that indicates if highlighting per tap (touch) is enabled
   */
  protected mHighLightPerTapEnabled: boolean = true;
  protected mHighLightPerLongPressEnabled: boolean = true;
  /**
   * If set to true, chart continues to scroll after touch up
   */
  private mDragDecelerationEnabled: boolean = false;
  /**
   * Deceleration friction coefficient in [0 ; 1] interval, higher values
   * indicate that speed will decrease slowly, for example if it set to 0, it
   * will stop immediately. 1 is an invalid value, and will be converted to
   * 0.999f automatically.
   */
  private mDragDecelerationFrictionCoef: number = 0.9;
  /**
   * default value-formatter, number of digits depends on provided chart-data
   */
  protected mDefaultValueFormatter: DefaultValueFormatter = new DefaultValueFormatter(0);
  /**
   * paint object used for drawing the description text in the bottom right
   * corner of the chart
   */
  protected mDescPaint: Paint = new Paint();
  /**
   * paint object for drawing the information text when there are no values in
   * the chart
   */
  protected mInfoPaint: Paint = new Paint();
  /**
   * the object representing the labels on the x-axis
   */
  protected mXAxis: XAxis | null = null;
  /**
   * if true, touch gestures are enabled on the chart
   */
  protected mTouchEnabled: boolean = true;
  /**
   * the object responsible for representing the description text
   */
  protected mDescription: Description | null = null;
  /**
   * the legend object containing all data associated with the legend
   */
  protected mLegend: Legend | null = null;
  /**
   * listener that is called when a value on the chart is selected
   */
  protected mSelectionListener: OnChartValueSelectedListener | null = null;
  protected mChartTouchListener: ChartTouchListener<ChartModel<ChartData<IDataSet<EntryOhos>>>> | null = null;
  /**
   * text that is displayed when the chart is empty
   */
  private mNoDataText: string = "No chart data available.";
  /**
   * Gesture listener for custom callbacks when making gestures on the chart.
   */
  private mGestureListener: OnChartGestureListener | null = null;
  /**
   * object responsible for rendering the data
   */
  protected mRenderer: DataRenderer | null = null;
  protected mHighlighter: IHighlighter | null = null;
  /**
   * object that manages the bounds and drawing constraints of the chart
   */
  protected mViewPortHandler: ViewPortHandler = new ViewPortHandler();
  protected mLegendRenderer: LegendRenderer | null = null;
  /**
   * object responsible for animations
   */
  protected mAnimator: ChartAnimator | null = null;
  /**
   * Extra offsets to be appended to the viewport
   */
  private mExtraTopOffset: number = 0
  private mExtraRightOffset: number = 0
  private mExtraBottomOffset: number = 0
  private mExtraLeftOffset: number = 0
  protected width: number = Utils.handleDataValues(50);
  protected height: number = Utils.handleDataValues(50);
  public GCEnable: boolean = false;

  protected mHitTestMode: HitTestMode = HitTestMode.Default;

  // private background: Color | string | number | Resource | null = null;
  // private workerInstance = new worker.ThreadWorker("workers/worker.js", { name: "chart worker" });

  /**
   * default constructor for initialization in code
   */
  constructor() {
    // this.init();
  }

  onAnimationUpdate: (animatorResult: AnimatorResult) => void = (animatorResult: AnimatorResult) => {
    this.invalidate();
  };

  abstract getYChartMin(): number;

  abstract getYChartMax(): number;

  abstract getMaxVisibleCount(): number;

  /**
   * initialize all paints and stuff
   */
  protected init() {
    // initialize the utils
    this.mAnimator = new ChartAnimator(this);
    Utils.init();
    this.mMaxHighlightDistance = Utils.handleDataValues(500);
    this.mDescription = new Description();
    this.mLegend = new Legend();

    this.mLegendRenderer = new LegendRenderer(this.mViewPortHandler, this.mLegend);
    this.mXAxis = new XAxis();
    this.mDescPaint = new Paint();
    this.mInfoPaint = new Paint();
    this.mInfoPaint.setColor(ChartColor.rgb(247, 189, 51)); // orange
    this.mInfoPaint.setTextAlign('center');
    this.mInfoPaint.setTextSize(Utils.handleDataValues(12));

    if (this.mLogEnabled)
      LogUtil.log("Chart.init()")
  }

  /**
   * Sets a new data object for the chart. The data object contains all values
   * and information needed for displaying.
   *
   * @param data
   */
  public setData(data: T | null) {

    this.mData = data;
    this.mOffsetsCalculated = false;

    if (data == null) {
      return;
    }

    // calculate how many digits are needed
    // 缺失方法
    this.setupDefaultFormatter(data.getYMin(), data.getYMax());

    if (this.mData) {
      const dataSets = this.mData.getDataSets();
      for (let i = 0; i < dataSets.size(); i++) {
        const item = dataSets.get(i);
        if (item.needsFormatter() || item.getValueFormatter() === this.mDefaultValueFormatter) {
          item.setValueFormatter(this.mDefaultValueFormatter);
        }
      }
    }


    // let the chart know there is new data
    this.notifyDataSetChanged();

    this.invalidate();

    if (this.mLogEnabled)
      LogUtil.log(ChartModel.LOG_TAG + ":Data is set.")
  }

  /**
   * Clears the chart from all data (sets it to null) and refreshes it (by
   * calling invalidate()).
   */
  public clear() {
    this.mData = null;
    this.mOffsetsCalculated = false;
    this.mIndicesToHighlight = null;
    if (this.mChartTouchListener) {
      this.mChartTouchListener.setLastHighlighted();
    }
    this.invalidate();
  }

  /**
   * Removes all DataSets (and thereby Entries) from the chart. Does not set the data object to null. Also refreshes the
   * chart by calling invalidate().
   */
  public clearValues() {
    if (this.mData) {
      this.mData.clearValues();
    }
    this.invalidate();
  }

  /**
   * Returns true if the chart is empty (meaning it's data object is either
   * null or contains no entries).
   *
   * @return
   */
  public isEmpty(): boolean {

    if (this.mData == null)
      return true;
    else {

      if (this.mData.getEntryCount() <= 0)
        return true;
      else
        return false;
    }
  }

  /**
   * Either posts a job immediately if the chart has already setup it's
   * dimensions or adds the job to the execution queue.
   *
   * @param job
   */
  public addViewportJob(job: MoveViewJob) {
    if (this.mViewPortHandler.hasChartDimens()) {
      job.run();
    } else {
      this.mJobs.add(job);
    }
  }

  /**
   * Lets the chart know its underlying data has changed and performs all
   * necessary recalculations. It is crucial that this method is called
   * every time data is changed dynamically. Not calling this method can lead
   * to crashes or unexpected behaviour.
   */
  public abstract notifyDataSetChanged();

  /**
   * Calculates the offsets of the chart to the border depending on the
   * position of an eventual legend or depending on the length of the y-axis
   * and x-axis labels and their position
   */
  protected abstract calculateOffsets();

  /**
   * Calculates the y-min and y-max value and the y-delta and x-delta value
   */
  protected abstract calcMinMax();

  /**
   * Calculates the required number of digits for the values that might be
   * drawn in the chart (if enabled), and creates the default-value-formatter
   */
  protected setupDefaultFormatter(min: number, max: number) {

    let reference: number = 0;

    if (this.mData == null || this.mData.getEntryCount() < 2) {

      reference = Math.max(Math.abs(min), Math.abs(max));
    } else {
      reference = Math.abs(max - min);
    }

    let digits: number = Utils.getDecimals(reference);

    // setup the formatter with a new number of digits
    this.mDefaultValueFormatter.setup(digits);
  }

  /**
   * flag that indicates if offsets calculation has already been done or not
   */
  private mOffsetsCalculated: boolean = false;
  public mChartSizeCorrected: boolean = false;

  protected onDraw(c: CanvasRenderingContext2D): void {
    if(this.GCEnable) {
      GCUtil.fullGC();
    }
    if (!this.mChartSizeCorrected) {
      return;
    }
    if (this.mData == null) {
      CanvasUtil.clearCanvas(c);
      let hasText: boolean = !this.strIsEmpty(this.mNoDataText);

      if (hasText) {
        let pt: MPPointF = this.getCenter();

        if (!pt) {
          return;
        }
        // let textPaint: TextPaint = new TextPaint();
        // if (this.mInfoPaint) {
        // textPaint.set(this.mInfoPaint);
        Utils.resetContext2DWithoutLine(c, this.mInfoPaint);
        if (this.mInfoPaint) {
          switch (this.mInfoPaint.getTextAlign()) {
            case 'start':
              pt.x = 0;
              c.strokeText(this.mNoDataText, pt.x, pt.y);
              break;

            case 'end':
              pt.x *= 2.0;
              c.strokeText(this.mNoDataText, pt.x, pt.y);
              break;

            default:
              c.strokeText(this.mNoDataText, pt.x, pt.y);
              break;
          }
        }
        // }
        return;
        // textPaint.setText(this.mNoDataText)
        // textPaint.setX(pt.x)
        // textPaint.setY(pt.y)
        // return [textPaint]
      }
    }
    if (!this.mOffsetsCalculated && this.mChartSizeCorrected) {

      this.calculateOffsets();
      this.mOffsetsCalculated = true;
    }
  }

  public strIsEmpty(str: string): boolean {
    return str == null || str.length == 0;
  }

  /**
   * Draws the description text in the bottom right corner of the chart (per default)
   */
  protected drawDescription(c: CanvasRenderingContext2D): void {
    // this.width = c.width;
    // this.height = c.height;

    // check if description should be drawn
    if (this.mDescription != null && this.mDescription.isEnabled()) {

      let position: MPPointF | null = this.mDescription.getPosition();

      if (this.mDescPaint) {
        this.mDescPaint.setFontFamily(this.mDescription.getTypeface());
        this.mDescPaint.setTextSize(this.mDescription.getTextSize());
        this.mDescPaint.setColor(this.mDescription.getTextColor());
        this.mDescPaint.setTextAlign(this.mDescription.getTextAlign());

        let x: number, y: number = 0;

        // if no position specified, draw on default position
        if (position == null) {
          x = c.width - this.mViewPortHandler.offsetRight() - this.mDescription.getXOffset();
          y = c.height - this.mViewPortHandler.offsetBottom() - this.mDescription.getYOffset();
        } else {
          x = position.x;
          y = position.y;
        }
        Utils.resetContext2DWithoutLine(c, this.mDescPaint);
        c.strokeText(this.mDescription.getText(), x, y);
        // if (this.mDescPaint) {
        //   (this.mDescPaint as TextPaint).setText(this.mDescription.getText());
        //   this.mDescPaint.setX(x);
        //   this.mDescPaint.setY(y);
        //   return [this.mDescPaint];
        // }
        // return [];
      }
      // return [];
    }

    // return [];
  }

  /**
   * ################ ################ ################ ################
   */
  /** BELOW THIS CODE FOR HIGHLIGHTING */

  /**
   * array of Highlight objects that reference the highlighted slices in the
   * chart
   */
  protected mIndicesToHighlight: Highlight[] | null = null;
  /**
   * The maximum distance in vp away from an entry causing it to highlight.
   */
  protected mMaxHighlightDistance: number = 0;
  protected mLastGesture = LastGesture.NONE;

  public setLastGestureSingleTap() {
    this.mLastGesture = LastGesture.SINGLE_TAP;
  }

  public setLastGestureLongPress() {
    this.mLastGesture = LastGesture.LONG_PRESS;
  }

  public getMaxHighlightDistance(): number {
    return this.mMaxHighlightDistance;
  }

  /**
   * Sets the maximum distance in screen dp a touch can be away from an entry to cause it to get highlighted.
   * Default: 500dp
   *
   * @param distDp
   */
  public setMaxHighlightDistance(distDp: number) {
    this.mMaxHighlightDistance = Utils.handleDataValues(distDp);
  }

  /**
   * Returns the array of currently highlighted values. This might a null or
   * empty array if nothing is highlighted.
   *
   * @return
   */
  public getHighlighted(): Highlight[] | null {
    return this.mIndicesToHighlight;
  }

  /**
   * Returns true if values can be highlighted via tap gesture, false if not.
   *
   * @return
   */
  public isHighlightPerTapEnabled(): boolean {
    return this.mHighLightPerTapEnabled;
  }

  public isHighlightPerLongPressEnabled(): boolean {
    return this.mHighLightPerLongPressEnabled;
  }

  /**
   * Set this to false to prevent values from being highlighted by tap gesture.
   * Values can still be highlighted via drag or programmatically. Default: true
   *
   * @param enabled
   */
  public setHighlightPerTapEnabled(enabled: boolean) {
    this.mHighLightPerTapEnabled = enabled;
  }

  public setHighlightPerLongPressEnabled(enabled: boolean) {
    this.mHighLightPerLongPressEnabled = enabled;
  }

  /**
   * Returns true if there are values to highlight, false if there are no
   * values to highlight. Checks if the highlight array is null, has a length
   * of zero or if the first object is null.
   *
   * @return
   */
  public valuesToHighlight(): boolean {
    return this.mIndicesToHighlight == null || this.mIndicesToHighlight.length <= 0
      || this.mIndicesToHighlight[0] == null ? false
      : true;
  }

  /**
   * Sets the last highlighted value for the touchlistener.
   *
   * @param highs
   */
  protected setLastHighlighted(highs: Highlight[]) {
    if (this.mChartTouchListener) {
      if (highs == null || highs.length <= 0 || highs[0] == null) {
        this.mChartTouchListener.setLastHighlighted();
      } else {
        this.mChartTouchListener.setLastHighlighted(highs[0]);
      }
    }
  }

  /**
   * Highlights the values at the given indices in the given DataSets. Provide
   * null or an empty array to undo all highlighting. This should be used to
   * programmatically highlight values.
   * This method *will not* call the listener.
   *
   * @param highs
   */
  public highlightValuesForArray(highs: Highlight[]) {

    // set the indices to highlight
    this.mIndicesToHighlight = highs;

    this.setLastHighlighted(highs);

    // redraw the chart
    this.invalidate();
  }

  /**
   * Highlights any y-value at the given x-value in the given DataSet.
   * Provide -1 as the dataSetIndex to undo all highlighting.
   * @param x The x-value to highlight
   * @param y The y-value to highlight. Supply `NaN` for "any"
   * @param dataSetIndex The dataset index to search in
   * @param dataIndex The data index to search in (only used in CombinedChartView currently)
   * @param callListener Should the listener be called for this change
   */
  public highlightValue(x: number, y?: number, dataSetIndex?: number, dataIndex?: number, callListener?: boolean) {
    if (y == null || y == undefined) {
      y = Number.NaN;
    }
    if (dataIndex == null || dataIndex == undefined) {
      dataIndex = -1;
    }
    if (callListener == null || callListener == undefined) {
      callListener = true;
    }
    // 缺失方法
    if (dataSetIndex != undefined) {
      if (dataSetIndex < 0 || dataSetIndex >= this.mData!.getDataSetCount()) {
        this.highlightValueForObject(null, callListener);
      } else {
        this.highlightValueForObject(new Highlight(x, y, dataSetIndex, dataIndex, 0, 0, 0, null), callListener);
      }
    }
  }

  /**
   * Highlights the value selected by touch gesture. Unlike
   * highlightValues(...), this generates a callback to the
   * OnChartValueSelectedListener.
   *
   * @param high         - the highlight object
   * @param callListener - call the listener
   */
  public highlightValueForObject(high: Highlight | null, callListener?: boolean) {

    if (callListener == null || callListener == undefined) {
      callListener = false;
    }
    let e: EntryOhos | null = null;

    if (high == null) {
      this.mIndicesToHighlight = null;
    } else {

      if (this.mLogEnabled)
        LogUtil.log(ChartModel.LOG_TAG + ":Highlighted: " + high.toString())

      // 缺失方法
      if (this.mData) {
        e = this.mData.getEntryForHighlight(high);
        // e = null;
        if (e == null) {
          this.mIndicesToHighlight = null;
          high = null;
        } else {

          // set the indices to highlight
          this.mIndicesToHighlight = [high];
        }
      }
    }
    if (this.mIndicesToHighlight) {
      this.setLastHighlighted(this.mIndicesToHighlight);
    }

    if (callListener && this.mSelectionListener != null) {
      let isHighLight = this.valuesToHighlight();
      if (!isHighLight) {
        this.mSelectionListener.onNothingSelected();
      } else {
        // notify the listener
        if (this.mSelectionListener && e && high) {
          this.mSelectionListener.onValueSelected(e, high);
        }
      }
    }

    // redraw the chart
    this.invalidateHighlight();
  }

  public abstract invalidate();

  public abstract invalidateHighlight();

  public abstract setContext2D(context2d: CanvasRenderingContext2D);

  public abstract onChartSizeChanged(newWidth: number, newHeight: number, oldWidth: number, oldHeight: number);

  /**
   * Returns the Highlight object (contains x-index and DataSet index) of the
   * selected value at the given touch point inside the Line-, Scatter-, or
   * CandleStick-Chart.
   *
   * @param x
   * @param y
   * @return
   */
  public getHighlightByTouchPoint(x: number, y: number): Highlight | null {

    if (this.mData == null) {
      LogUtil.error(ChartModel.LOG_TAG + ":Can't select by touch. No data set.")
      return null;
    } else {
      let hghLighter = this.getHighlighter();
      if (hghLighter) {
        return hghLighter.getHighlight(x, y);
      } else {
        return null;
      }
    }
  }

  /**
   * Set a new (e.g. custom) ChartTouchListener NOTE: make sure to
   * setTouchEnabled(true); if you need touch gestures on the chart
   *
   * @param l
   */

  public setOnTouchListener(l: ChartTouchListener<ChartModel<ChartData<IDataSet<EntryOhos>>>>) {
    this.mChartTouchListener = l;
  }

  /**
   * Returns an instance of the currently active touch listener.
   *
   * @return
   */
  public getOnTouchListener(): ChartTouchListener<ChartModel<ChartData<IDataSet<EntryOhos>>>> | null {
    return this.mChartTouchListener;
  }

  /**
   * ################ ################ ################ ################
   */
  /** BELOW CODE IS FOR THE MARKER VIEW */

  /**
   * if set to true, the marker view is drawn when a value is clicked
   */
  protected mDrawMarkers: boolean = true;
  protected mDrawLongPressMarkers: boolean = true;
  /**
   * the view that represents the marker
   */
  protected mMarker: IMarker | null = null;
  protected mLongPressMarker: IMarker | null = null;

  /**
   * draws all MarkerViews on the highlighted positions
   */
  protected drawMarkers(c: CanvasRenderingContext2D): void {
    if (this.mLastGesture != LastGesture.SINGLE_TAP) {
      return;
    }
    // let paints: Paint[] = [];

    // if there is no marker view or drawing marker is disabled
    if (this.mMarker == null || !this.isDrawMarkersEnabled() || !this.valuesToHighlight())
      return;

    if (this.mIndicesToHighlight && this.mData) {
      for (let i = 0; i < this.mIndicesToHighlight.length; i++) {

        let highlight: Highlight = this.mIndicesToHighlight[i];

        let dataSet: IDataSet<EntryOhos> | null = this.mData.getDataSetByIndex(highlight.getDataSetIndex()) as IDataSet<EntryOhos>;

        if (dataSet) {
          let e: EntryOhos | null = this.mData.getEntryForHighlight(this.mIndicesToHighlight[i]);
          if (!e) {
            continue;
          }
          let entryIndex: number = dataSet.getEntryIndexByEntry(e);
          // make sure entry not null
          if (e == null || this.mAnimator == null || entryIndex > dataSet.getEntryCount() * this.mAnimator.getPhaseX())
            continue;

          let pos: number[] = this.getMarkerPosition(highlight);

          // check bounds
          if (!this.mViewPortHandler.isInBounds(pos[0], pos[1]))
            continue;

          if (this.mMarker) {
            // callbacks to update the content
            // this.mMarker.refreshContent(e, highlight);
            this.mMarker.draw(c, pos[0], pos[1], e, highlight);
            // draw the marker
            // if (paints ) {
            //   paints.concat(this.mMarker.draw(pos[0], pos[1]));
            // }
          }
        }
      }
    }
    // return paints;
  }

  protected drawLongPressMarkers(c: CanvasRenderingContext2D): void {
    if (this.mLastGesture != LastGesture.LONG_PRESS) {
      return;
    }
    if (this.mLongPressMarker == null || !this.isDrawLongPressMarkersEnabled() || !this.valuesToHighlight()) {
      return;
    }

    if (this.mIndicesToHighlight && this.mData) {
      for (let i = 0; i < this.mIndicesToHighlight.length; i++) {
        let highlight: Highlight = this.mIndicesToHighlight[i];
        let dataSet: IDataSet<EntryOhos> | null = this.mData.getDataSetByIndex(highlight.getDataSetIndex()) as IDataSet<EntryOhos>;
        if (dataSet) {
          let e: EntryOhos | null = this.mData.getEntryForHighlight(this.mIndicesToHighlight[i]);
          if (!e) {
            continue;
          }
          let entryIndex: number = dataSet.getEntryIndexByEntry(e);
          if (e == null || this.mAnimator == null || entryIndex > dataSet.getEntryCount() * this.mAnimator.getPhaseX()) {
            continue;
          }
          let pos: number[] = this.getMarkerPosition(highlight);
          if (!this.mViewPortHandler.isInBounds(pos[0], pos[1])) {
            continue;
          }
          if (this.mLongPressMarker) {
            this.mLongPressMarker.draw(c, pos[0], pos[1], e, highlight);
          }
        }
      }
    }
  }

  /**
   * Returns the actual position in pixels of the MarkerView for the given
   * Highlight object.
   *
   * @param high
   * @return
   */
  protected getMarkerPosition(high: Highlight): number[] {
    return [high.getDrawX(), high.getDrawY()];
  }


  /** CODE BELOW THIS RELATED TO ANIMATION */

  /**
   * Returns the animator responsible for animating chart values.
   *
   * @return
   */
  public getAnimator(): ChartAnimator | null {
    return this.mAnimator;
  }

  /**
   * If set to true, chart continues to scroll after touch up default: true
   */
  public isDragDecelerationEnabled(): boolean {
    return this.mDragDecelerationEnabled;
  }

  /**
   * If set to true, chart continues to scroll after touch up. Default: true.
   *
   * @param enabled
   */
  public setDragDecelerationEnabled(enabled: boolean) {
    this.mDragDecelerationEnabled = enabled;
  }

  /**
   * Returns drag deceleration friction coefficient
   *
   * @return
   */
  public getDragDecelerationFrictionCoef(): number {
    return this.mDragDecelerationFrictionCoef;
  }

  /**
   * Deceleration friction coefficient in [0 ; 1] interval, higher values
   * indicate that speed will decrease slowly, for example if it set to 0, it
   * will stop immediately. 1 is an invalid value, and will be converted to
   * 0.999f automatically.
   *
   * @param newValue
   */
  public setDragDecelerationFrictionCoef(newValue: number) {

    if (newValue < 0)
      newValue = 0;

    if (newValue >= 1)
      newValue = 0.999;

    this.mDragDecelerationFrictionCoef = newValue;
  }


  /** CODE BELOW FOR PROVIDING EASING FUNCTIONS */

  /**
   * Animates the drawing / rendering of the chart on both x- and y-axis with
   * the specified animation time. If animate(...) is called, no further
   * calling of invalidate() is necessary to refresh the chart. ANIMATIONS
   *
   * @param durationMillisX
   * @param durationMillisY
   * @param easingX         a custom easing function to be used on the animation phase
   * @param easingY         a custom easing function to be used on the animation phase
   */
  // @RequiresApi(11)
  public animateXY(durationMillisX: number, durationMillisY: number): void;

  public animateXY(durationMillisX: number, durationMillisY: number, easingX: string): void;

  public animateXY(durationMillisX: number, durationMillisY: number, easingX: string, easingY: string): void;

  public animateXY(durationMillisX: number, durationMillisY: number, easingX?: string, easingY?: string): void {
    if (!this.mAnimator) {
      return;
    }
    if (easingX && easingY) {
      this.mAnimator.animateXY(durationMillisX, durationMillisY, easingX, easingY);
    } else if (easingX) {
      this.mAnimator.animateXY(durationMillisX, durationMillisY, easingX);
    } else {
      this.mAnimator.animateXY(durationMillisX, durationMillisY);
    }
  }


  /**
   * Animates the rendering of the chart on the x-axis with the specified
   * animation time. If animate(...) is called, no further calling of
   * invalidate() is necessary to refresh the chart. ANIMATIONS ONLY WORK FOR
   *
   * @param durationMillis
   * @param easing         a custom easing function to be used on the animation phase
   */
  // @RequiresApi(11)
  public animateX(durationMillis: number): void;

  public animateX(durationMillis: number, easing: string): void;

  public animateX(durationMillis: number, easing?: string): void {
    if (!this.mAnimator) {
      return;
    }
    if (easing) {
      this.mAnimator.animateX(durationMillis, easing);
    } else {
      this.mAnimator.animateX(durationMillis);
    }

  }

  /**
   * Animates the rendering of the chart on the y-axis with the specified
   * animation time. If animate(...) is called, no further calling of
   * invalidate() is necessary to refresh the chart. ANIMATIONS ONLY WORK FOR
   *
   * @param durationMillis
   * @param easing         a custom easing function to be used on the animation phase
   */
  // @RequiresApi(11)
  public animateY(durationMillis: number): void;

  public animateY(durationMillis: number, easing: string): void;

  public animateY(durationMillis: number, easing?: string): void {
    if (!this.mAnimator) {
      return;
    }
    if (easing) {
      this.mAnimator.animateY(durationMillis, easing);
    } else {
      this.mAnimator.animateY(durationMillis);
    }

  }

  /**
   * ################ ################ ################ ################
   */
  /** BELOW THIS ONLY GETTERS AND SETTERS */

  /**
   * Returns the object representing all x-labels, this method can be used to
   * acquire the XAxis object and modify it (e.g. change the position of the
   * labels, styling, etc.)
   *
   * @return
   */
  public getXAxis(): XAxis | null {
    return this.mXAxis;
  }

  /**
   * Returns the default IValueFormatter that has been determined by the chart
   * considering the provided minimum and maximum values.
   *
   * @return
   */
  public getDefaultValueFormatter(): IValueFormatter {
    return this.mDefaultValueFormatter;
  }

  /**
   * set a selection listener for the chart
   *
   * @param l
   */
  public setOnChartValueSelectedListener(l: OnChartValueSelectedListener) {
    this.mSelectionListener = l;
  }

  /**
   * Sets a gesture-listener for the chart for custom callbacks when executing
   * gestures on the chart surface.
   *
   * @param l
   */
  public setOnChartGestureListener(l: OnChartGestureListener): void {
    this.mGestureListener = l;
  }

  /**
   * Returns the custom gesture listener.
   *
   * @return
   */
  public getOnChartGestureListener(): OnChartGestureListener | null {
    return this.mGestureListener;
  }

  /**
   * returns the current y-max value across all DataSets
   *
   * @return
   */
  public getYMax(): number {
    // 缺失方法
    if (this.mData) {
      return this.mData.getYMax();
    }
    return 0;
  }

  /**
   * returns the current y-min value across all DataSets
   *
   * @return
   */
  public getYMin(): number {
    // 缺失方法
    if (this.mData) {
      return this.mData.getYMin();
    }
    return 0;
  }

  public getXChartMax(): number {
    if (this.mXAxis) {
      return this.mXAxis.mAxisMaximum;
    }
    return 0;
  }

  public getXChartMin(): number {
    if (this.mXAxis) {
      return this.mXAxis.mAxisMinimum;
    }
    return 0;
  }

  public getXRange(): number {
    if (this.mXAxis) {
      return this.mXAxis.mAxisRange;
    }
    return 0;
  }

  /**
   * Returns a recyclable MPPointF instance.
   * Returns the center point of the chart (the whole View) in pixels.
   *
   * @return
   */
  public getCenter(): MPPointF {
    return MPPointF.getInstance(this.width / 2, this.height / 2);
  }

  public getWidth(): number {
    return this.width
  }

  public getHeight(): number {
    return this.height
  }

  /**
   * Returns a recyclable MPPointF instance.
   * Returns the center of the chart taking offsets under consideration.
   * (returns the center of the content rectangle)
   *
   * @return
   */
  public getCenterOffsets(): MPPointF | null {
    return this.mViewPortHandler.getContentCenter();
  }

  /**
   * Sets extra offsets (around the chart view) to be appended to the
   * auto-calculated offsets.
   *
   * @param left
   * @param top
   * @param right
   * @param bottom
   */
  public setExtraOffsets(left: number, top: number, right: number, bottom: number) {
    this.setExtraLeftOffset(left);
    this.setExtraTopOffset(top);
    this.setExtraRightOffset(right);
    this.setExtraBottomOffset(bottom);
  }

  /**
   * Set an extra offset to be appended to the viewport's top
   */
  public setExtraTopOffset(offset: number) {
    this.mExtraTopOffset = Utils.handleDataValues(offset);
  }

  /**
   * @return the extra offset to be appended to the viewport's top
   */
  public getExtraTopOffset(): number {
    return this.mExtraTopOffset;
  }

  /**
   * Set an extra offset to be appended to the viewport's right
   */
  public setExtraRightOffset(offset: number) {
    this.mExtraRightOffset = Utils.handleDataValues(offset);
  }

  /**
   * @return the extra offset to be appended to the viewport's right
   */
  public getExtraRightOffset(): number {
    return this.mExtraRightOffset;
  }

  /**
   * Set an extra offset to be appended to the viewport's bottom
   */
  public setExtraBottomOffset(offset: number) {
    this.mExtraBottomOffset = Utils.handleDataValues(offset);
  }

  /**
   * @return the extra offset to be appended to the viewport's bottom
   */
  public getExtraBottomOffset(): number {
    return this.mExtraBottomOffset;
  }

  /**
   * Set an extra offset to be appended to the viewport's left
   */
  public setExtraLeftOffset(offset: number) {
    this.mExtraLeftOffset = Utils.handleDataValues(offset);
  }

  /**
   * @return the extra offset to be appended to the viewport's left
   */
  public getExtraLeftOffset(): number {
    return this.mExtraLeftOffset;
  }

  /**
   * Set this to true to enable logcat outputs for the chart. Beware that
   * logcat output decreases rendering performance. Default: disabled.
   *
   * @param enabled
   */
  public setLogEnabled(enabled: boolean) {
    this.mLogEnabled = enabled;
  }

  /**
   * Returns true if log-output is enabled for the chart, fals if not.
   *
   * @return
   */
  public isLogEnabled(): boolean {
    return this.mLogEnabled;
  }

  /**
   * Sets the text that informs the user that there is no data available with
   * which to draw the chart.
   *
   * @param text
   */
  public setNoDataText(text: string) {
    this.mNoDataText = text;
  }

  /**
   * Sets the color of the no data text.
   *
   * @param color
   */
  public setNoDataTextColor(color: number | string) {
    if (this.mInfoPaint) {
      this.mInfoPaint.setColor(color);
    }
  }

  /**
   * Sets the typeface to be used for the no data text.
   *
   * @param tf
   */
  public setNoDataTextTypeface(tf: FontFamily) {
    if (this.mInfoPaint) {
      this.mInfoPaint.setFontFamily(tf);
    }
  }

  /**
   * alignment of the no data text
   *
   * @param align
   */
  public setNoDataTextAlignment(align: CanvasTextAlign) {
    if (this.mInfoPaint) {
      this.mInfoPaint.setTextAlign(align);
    }
  }

  /**
   * Set this to false to disable all gestures and touches on the chart,
   * default: true
   *
   * @param enabled
   */
  public setTouchEnabled(enabled: boolean) {
    this.mTouchEnabled = enabled;
  }

  public getTouchEnabled(): boolean {
    return this.mTouchEnabled;
  }

  /**
   * sets the marker that is displayed when a value is clicked on the chart
   *
   * @param marker
   */
  public setMarker(marker: IMarker) {
    this.mMarker = marker;
  }

  public setLongPressMarker(marker: IMarker) {
    this.mLongPressMarker = marker;
  }

  /**
   * returns the marker that is set as a marker view for the chart
   *
   * @return
   */
  public getMarker(): IMarker | null {
    return this.mMarker;
  }

  public getLongPressMarker(): IMarker | null {
    return this.mLongPressMarker;
  }

  public setMarkerView(v: IMarker) {
    this.setMarker(v);
  }

  public getMarkerView(): IMarker | null {
    return this.getMarker();
  }

  /**
   * Sets a new Description object for the chart.
   *
   * @param desc
   */
  public setDescription(desc: Description) {
    this.mDescription = desc;
  }

  /**
   * Returns the Description object of the chart that is responsible for holding all information related
   * to the description text that is displayed in the bottom right corner of the chart (by default).
   *
   * @return
   */
  public getDescription(): Description | null {
    return this.mDescription;
  }

  /**
   * Returns the Legend object of the chart. This method can be used to get an
   * instance of the legend in order to customize the automatically generated
   * Legend.
   *
   * @return
   */
  public getLegend(): Legend | null {
    return this.mLegend;
  }

  /**
   * Returns the renderer object responsible for rendering / drawing the
   * Legend.
   *
   * @return
   */
  public getLegendRenderer(): LegendRenderer | null {
    return this.mLegendRenderer;
  }

  /**
   * Returns the rectangle that defines the borders of the chart-value surface
   * (into which the actual values are drawn).
   *
   * @return
   */
  public getContentRect(): MyRect {
    return this.mViewPortHandler.getContentRect();
  }

  /**
   * disables intercept touchevents
   */
  public disableScroll() {
    //        ViewParent parent = getParent();
    //        if (parent != null)
    //            parent.requestDisallowInterceptTouchEvent(true);
  }

  /**
   * enables intercept touchevents
   */
  public enableScroll() {
    //        ViewParent parent = getParent();
    //        if (parent != null)
    //            parent.requestDisallowInterceptTouchEvent(false);
  }

  /**
   * paint for the grid background (only line and barchart)
   */
  public static PAINT_GRID_BACKGROUND: number = 4;
  /**
   * paint for the info text that is displayed when there are no values in the
   * chart
   */
  public static PAINT_INFO: number = 7;
  /**
   * paint for the description text in the bottom right corner
   */
  public static PAINT_DESCRIPTION: number = 11;
  /**
   * paint for the hole in the middle of the pie chart
   */
  public static PAINT_HOLE: number = 13;
  /**
   * paint for the text in the middle of the pie chart
   */
  public static PAINT_CENTER_TEXT: number = 14;
  /**
   * paint used for the legend
   */
  public static PAINT_LEGEND_LABEL: number = 18;

  /**
   * set a new paint object for the specified parameter in the chart e.g.
   * Chart.PAINT_VALUES
   *
   * @param p     the new paint object
   * @param which Chart.PAINT_VALUES, Chart.PAINT_GRID, Chart.PAINT_VALUES,
   *              ...
   */
  public setPaint(p: Paint, which: number) {

    switch (which) {
      case ChartModel.PAINT_INFO:
      // case 7:
        this.mInfoPaint = p;
        break;
      case ChartModel.PAINT_DESCRIPTION:
      // case 11:
        this.mDescPaint = p;
        break;
    }
  }

  /**
   * Returns the paint object associated with the provided constant.
   *
   * @param which e.g. Chart.PAINT_LEGEND_LABEL
   * @return
   */
  public getPaint(which: number): Paint | null {
    switch (which) {
      case ChartModel.PAINT_INFO:
      // case 7:
        return this.mInfoPaint;
      case ChartModel.PAINT_DESCRIPTION:
      // case 11:
        return this.mDescPaint;
    }

    return null;
  }

  public isDrawMarkerViewsEnabled(): boolean {
    return this.isDrawMarkersEnabled();
  }

  public setDrawMarkerViews(enabled: boolean) {
    this.setDrawMarkers(enabled);
  }

  /**
   * returns true if drawing the marker is enabled when tapping on values
   * (use the setMarker(IMarker marker) method to specify a marker)
   *
   * @return
   */
  public isDrawMarkersEnabled(): boolean {
    return this.mDrawMarkers;
  }

  public isDrawLongPressMarkersEnabled(): boolean {
    return this.mDrawLongPressMarkers;
  }

  /**
   * Set this to true to draw a user specified marker when tapping on
   * chart values (use the setMarker(IMarker marker) method to specify a
   * marker). Default: true
   *
   * @param enabled
   */
  public setDrawMarkers(enabled: boolean) {
    this.mDrawMarkers = enabled;
  }

  public setDrawLongPressMarkers(enabled: boolean) {
    this.mDrawLongPressMarkers = enabled;
  }

  /**
   * Returns the ChartData object that has been set for the chart.
   *
   * @return
   */
  public getData(): T | null {
    return this.mData;
  }

  /**
   * Returns the ViewPortHandler of the chart that is responsible for the
   * content area of the chart and its offsets and dimensions.
   *
   * @return
   */
  public getViewPortHandler(): ViewPortHandler {
    return this.mViewPortHandler;
  }

  /**
   * Returns the Renderer object the chart uses for drawing data.
   *
   * @return
   */
  public getRenderer(): DataRenderer | null {
    return this.mRenderer;
  }

  /**
   * Sets a new DataRenderer object for the chart.
   *
   * @param renderer
   */
  public setRenderer(renderer: DataRenderer) {

    if (renderer != null)
      this.mRenderer = renderer;
  }

  public getHighlighter(): IHighlighter | null {
    return this.mHighlighter;
  }

  /**
   * Sets a custom highligher object for the chart that handles / processes
   * all highlight touch events performed on the chart-view.
   *
   * @param highlighter
   */
  public setHighlighter(highlighter: ChartHighlighter<BarLineScatterCandleBubbleDataProvider>) {
    this.mHighlighter = highlighter;
  }

  /**
   * Returns a recyclable MPPointF instance.
   *
   * @return
   */
  public getCenterOfView(): MPPointF {
    return this.getCenter();
  }

  /**
   * Returns the bitmap that represents the chart.
   *
   * @return
   */
  // public getChartBitmap(c:CanvasRenderingContext2D): ChartPixelMap {
  //   // // Define a bitmap with the same size as the view
  //   // let returnedBitmap: Paint[] = [];
  //   // // Get the view's background
  //   // let background = this.getBackground();
  //   // if (background == null)
  //   // // has background drawable, then draw it on the canvas
  //   // background = "#ffffff"
  //   // // draw the view on the canvas
  //   // //    this.draw();
  //   // // return the bitmap
  //   // return returnedBitmap;
  //   let chartPixelMap = new ChartPixelMap();
  //   let setting  = new RenderingContextSettings(true);
  //   let offCanvasContext = new OffscreenCanvasRenderingContext2D(this.getWidth(),this.getHeight(),setting);
  //
  // }

  // setBackground(background: Color | string | number | Resource) {
  //   this.background = background;
  // }
  //
  // getBackground(): Color | string | number | Resource| null {
  //   return this.background;
  // }

  //    /**
  //     * Saves the current chart state with the given name to the given path on
  //     * the sdcard leaving the path empty "" will put the saved file directly on
  //     * the SD card chart is saved as a PNG image, example:
  //     * saveToPath("myfilename", "foldername1/foldername2");
  //     *
  //     * @param title
  //     * @param pathOnSD e.g. "folder1/folder2/folder3"
  //     * @return returns true on success, false on error
  //     */
  //    public boolean saveToPath(String title, String pathOnSD) {
  //
  //
  //
  //        Bitmap b = getChartBitmap();
  //
  //        OutputStream stream = null;
  //        try {
  //            stream = new FileOutputStream(Environment.getExternalStorageDirectory().getPath()
  //                    + pathOnSD + "/" + title
  //                    + ".png");
  //
  //            /*
  //             * Write bitmap to file using JPEG or PNG and 40% quality hint for
  //             * JPEG.
  //             */
  //            b.compress(CompressFormat.PNG, 40, stream);
  //
  //            stream.close();
  //        } catch (Exception e) {
  //            e.printStackTrace();
  //            return false;
  //        }
  //
  //        return true;
  //    }

  //    /**
  //     * Saves the current state of the chart to the gallery as an image type. The
  //     * compression must be set for JPEG only. 0 == maximum compression, 100 = low
  //     * compression (high quality). NOTE: Needs permission WRITE_EXTERNAL_STORAGE
  //     *
  //     * @param fileName        e.g. "my_image"
  //     * @param subFolderPath   e.g. "ChartPics"
  //     * @param fileDescription e.g. "Chart details"
  //     * @param format          e.g. Bitmap.CompressFormat.PNG
  //     * @param quality         e.g. 50, min = 0, max = 100
  //     * @return returns true if saving was successful, false if not
  //     */
  //    public boolean saveToGallery(String fileName, String subFolderPath, String fileDescription, Bitmap.CompressFormat
  //            format, int quality) {
  //        // restrain quality
  //        if (quality < 0 || quality > 100)
  //            quality = 50;
  //
  //        long currentTime = System.currentTimeMillis();
  //
  //        File extBaseDir = Environment.getExternalStorageDirectory();
  //        File file = new File(extBaseDir.getAbsolutePath() + "/DCIM/" + subFolderPath);
  //        if (!file.exists()) {
  //            if (!file.mkdirs()) {
  //                return false;
  //            }
  //        }
  //
  //        String mimeType = "";
  //        switch (format) {
  //            case PNG:
  //                mimeType = "image/png";
  //                if (!fileName.endsWith(".png"))
  //                    fileName += ".png";
  //                break;
  //            case WEBP:
  //                mimeType = "image/webp";
  //                if (!fileName.endsWith(".webp"))
  //                    fileName += ".webp";
  //                break;
  //            case JPEG:
  //            default:
  //                mimeType = "image/jpeg";
  //                if (!(fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")))
  //                    fileName += ".jpg";
  //                break;
  //        }
  //
  //        String filePath = file.getAbsolutePath() + "/" + fileName;
  //        FileOutputStream out = null;
  //        try {
  //            out = new FileOutputStream(filePath);
  //
  //            Bitmap b = getChartBitmap();
  //            b.compress(format, quality, out);
  //
  //            out.flush();
  //            out.close();
  //
  //        } catch (IOException e) {
  //            e.printStackTrace();
  //
  //            return false;
  //        }
  //
  //        long size = new File(filePath).length();
  //
  //        ContentValues values = new ContentValues(8);
  //
  //        // store the details
  //        values.put(Images.Media.TITLE, fileName);
  //        values.put(Images.Media.DISPLAY_NAME, fileName);
  //        values.put(Images.Media.DATE_ADDED, currentTime);
  //        values.put(Images.Media.MIME_TYPE, mimeType);
  //        values.put(Images.Media.DESCRIPTION, fileDescription);
  //        values.put(Images.Media.ORIENTATION, 0);
  //        values.put(Images.Media.DATA, filePath);
  //        values.put(Images.Media.SIZE, size);
  //
  //        return getContext().getContentResolver().insert(Images.Media.EXTERNAL_CONTENT_URI, values) != null;
  //    }
  //
  //    /**
  //     * Saves the current state of the chart to the gallery as a JPEG image. The
  //     * filename and compression can be set. 0 == maximum compression, 100 = low
  //     * compression (high quality). NOTE: Needs permission WRITE_EXTERNAL_STORAGE
  //     *
  //     * @param fileName e.g. "my_image"
  //     * @param quality  e.g. 50, min = 0, max = 100
  //     * @return returns true if saving was successful, false if not
  //     */
  //    public boolean saveToGallery(String fileName, int quality) {
  //        return saveToGallery(fileName, "", "mpchart-Library Save", Bitmap.CompressFormat.PNG, quality);
  //    }
  //
  //    /**
  //     * Saves the current state of the chart to the gallery as a PNG image.
  //     * NOTE: Needs permission WRITE_EXTERNAL_STORAGE
  //     *
  //     * @param fileName e.g. "my_image"
  //     * @return returns true if saving was successful, false if not
  //     */
  //    public boolean saveToGallery(String fileName) {
  //        return saveToGallery(fileName, "", "mpchart-Library Save", Bitmap.CompressFormat.PNG, 40);
  //    }
  //
  /**
   * tasks to be done after the view is setup
   */
  //   protected mJobs: JArrayList<Runnable> = new JArrayList<Runnable>();
  //
  //   public removeViewportJob(job: Runnable) {
  //     this.workerInstance.removeEventListener(job._type)
  //     this.mJobs.remove(job);
  //   }
  //
  //   public clearAllViewportJobs() {
  //     this.workerInstance.removeAllListener();
  //     this.mJobs.clear();
  //   }
  //
  // /**
  //   * Either posts a job immediately if the chart has already setup it's
  //   * dimensions or adds the job to the execution queue.
  //   *
  //   * @param job
  //   */
  //   public addViewportJob(job: Runnable) {
  //
  //     if (this.mViewPortHandler.hasChartDimens()) {
  //       this.post(job);
  //     } else {
  //       this.mJobs.add(job);
  //     }
  //   }
  //
  //   protected post(job: Runnable) {
  //     let event: DispatchEvent = { type: job._type , timeStamp:0};
  //     this.workerInstance.dispatchEvent(event);
  //   }
  //
  // /**
  //   * Returns all jobs that are scheduled to be executed after
  //   * onSizeChanged(...).
  //   *
  //   * @return
  //   */
  //   public getJobs(): JArrayList<Runnable> {
  //     return this.mJobs;
  //   }

  //    @Override
  //    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
  //
  //        for (int i = 0; i < getChildCount(); i++) {
  //            getChildAt(i).layout(left, top, right, bottom);
  //        }
  //    }
  //
  //    @Override
  //    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
  //        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
  //        int size = (int) Utils.convertDpToPixel(50f);
  //        setMeasuredDimension(
  //                Math.max(getSuggestedMinimumWidth(),
  //                        resolveSize(size,
  //                                widthMeasureSpec)),
  //                Math.max(getSuggestedMinimumHeight(),
  //                        resolveSize(size,
  //                                heightMeasureSpec)));
  //    }
  //
  //    @Override
  public onSizeChanged(w: number, h: number, oldw: number, oldh: number): void {
    if (this.mLogEnabled)
      LogUtil.log(ChartModel.LOG_TAG + "OnSizeChanged()");
    this.mChartSizeCorrected = true;
    this.width = w;
    this.height = h;
    if (w > 0 && h > 0 && w < 10000 && h < 10000) {
      if (this.mLogEnabled)
        LogUtil.log(ChartModel.LOG_TAG + "Setting chart dimens, width: " + w + ", height: " + h);
      this.mViewPortHandler.setChartDimens(w, h);
    } else {
      if (this.mLogEnabled)
        LogUtil.warn(ChartModel.LOG_TAG + "*Avoiding* setting chart dimens! width: " + w + ", height: " + h);
    }

    // This may cause the chart view to mutate properties affecting the view port --
    //   lets do this before we try to run any pending jobs on the view port itself
    this.notifyDataSetChanged();

    let jobs = this.mJobs;
    let length = jobs.length();
    for (let i = 0; i < length; i++) {
      jobs.get(i).run();
    }
    jobs.clear();
  }

  //
  /**
   * Setting this to true will set the layer-type HARDWARE for the view, false
   * will set layer-type SOFTWARE.
   *
   * @param enabled
   */
  public setHardwareAccelerationEnabled(enabled: boolean) {

    //        if (enabled)
    //            setLayerType(View.LAYER_TYPE_HARDWARE, null);
    //        else
    //            setLayerType(View.LAYER_TYPE_SOFTWARE, null);
  }

  //    @Override
  //    protected void onDetachedFromWindow() {
  //        super.onDetachedFromWindow();
  //
  //        //Log.i(LOG_TAG, "Detaching...");
  //
  //        if (mUnbind)
  //            unbindDrawables(this);
  //    }

  /**
   * unbind flag
   */
  private mUnbind: boolean = false;

  //    /**
  //     * Unbind all drawables to avoid memory leaks.
  //     *
  //     * @param view
  //     */
  //    private void unbindDrawables(View view) {
  //
  //        if (view.getBackground() != null) {
  //            view.getBackground().setCallback(null);
  //        }
  //        if (view instanceof ViewGroup) {
  //            for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
  //                unbindDrawables(((ViewGroup) view).getChildAt(i));
  //            }
  //            ((ViewGroup) view).removeAllViews();
  //        }
  //    }
  //
  /**
   * Set this to true to enable "unbinding" of drawables. When a View is detached
   * from a window. This helps avoid memory leaks.
   * Default: false
   *
   * @param enabled
   */
  public setUnbindEnabled(enabled: boolean) {
    this.mUnbind = enabled;
  }

  /**
   * 设置绘制多少次后调用垃圾回收的阈值
   * @param gcThreshold
   */
  public setGCThreadHold(gcThreshold: number) {
    GCUtil.gcThreshold = gcThreshold;
  }

  /**
   * 获取绘制多少次后调用垃圾回收的阈值
   * @returns
   */
  public getGCThreadHold(): number {
    return GCUtil.gcThreshold;
  }

  /**
   * Sets the hit test mode.
   *
   * @param {HitTestMode} hitTestMode - The hit test mode to set.
   */
  public setHitTestMode(hitTestMode: HitTestMode) {
    this.mHitTestMode = hitTestMode;
  }

  /**
   * Gets the current hit test mode.
   *
   * @returns {HitTestMode} The current hit test mode.
   */
  public getHitTestMode(): HitTestMode {
    return this.mHitTestMode;
  }
}
