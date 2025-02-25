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

import Highlight from '../highlight/Highlight';
import IPieDataSet from '../interfaces/datasets/IPieDataSet';
import { JArrayList } from '../utils/JArrayList';
import ChartData from './ChartData';
import EntryOhos from './EntryOhos'
import Utils from '../utils/Utils';
import { LogUtil } from '../utils/LogUtil';

/**
 * A PieData object can only represent one DataSet. Unlike all other charts, the
 * legend labels of the PieChart are created from the x-values array, and not
 * from the DataSet labels. Each PieData object can only represent one
 * PieDataSet (multiple PieDataSets inside a single PieChart are not possible).
 *
 */
export default class PieData extends ChartData<IPieDataSet> {
  constructor(dataSet?: IPieDataSet) {
    if (dataSet) {
      super([dataSet]);
    } else {
      super();
    }
  }

  // public PieData(IPieDataSet dataSet) {
  //     super(dataSet);
  // }

  /**
   * Sets the PieDataSet this data object should represent.
   *
   * @param dataSet
   */
  public setDataSet(dataSet: IPieDataSet): void {
    if (this.mDataSets) {
      this.mDataSets.clear();
      this.mDataSets.add(dataSet);
      this.notifyDataChanged();
    }
  }

  /**
   * Returns the DataSet this PieData object represents. A PieData object can
   * only contain one DataSet.
   *
   * @return
   */
  public getDataSet(): IPieDataSet {
    return this.mDataSets.get(0);
  }

  // @Override
  public getDataSets(): JArrayList<IPieDataSet> {
    let dataSets: JArrayList<IPieDataSet> = super.getDataSets();

    if (dataSets.size() < 1) {
      LogUtil.log("mpchart",
        "Found multiple data sets while pie chart only allows one");
    }

    return dataSets;
  }

  /**
   * The PieData object can only have one DataSet. Use getDataSet() method instead.
   *
   * @param index
   * @return
   */
  // @Override
  public getDataSetByIndex(index: number): IPieDataSet | null {
    return index == 0 ? this.getDataSet() : null;
  }

  // @Override
  public getDataSetByLabel(label: string, ignorecase: boolean): IPieDataSet | null {
    return ignorecase ? Utils.equalsIgnoreCase(label, this.mDataSets.get(0).getLabel()) ? this.mDataSets.get(0)
                                                                                        : null : label == this.mDataSets.get(0)
      .getLabel() ? this.mDataSets.get(0) : null;
  }


  // @Override
  public getEntryForHighlight(highlight: Highlight): EntryOhos {
    return this.getDataSet().getEntryForIndex( /*(int) */
      highlight.getX());
  }

  /**
   * Returns the sum of all values in this PieData object.
   *
   * @return
   */
  public getYValueSum(): number {

    let sum: number = 0;

    for (let i: number = 0; i < this.getDataSet().getEntryCount(); i++)
      sum += this.getDataSet().getEntryForIndex(i).getY();


    return sum;
  }
}
