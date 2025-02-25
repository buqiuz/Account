/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { relationalStore } from '@kit.ArkData';
import { BillItem } from '../../../viewmodel/BillItem';
import CommonConstants from '../../constants/CommonConstants';
import Rdb from '../Rdb';

export default class BillItemTable {
  private accountTable = new Rdb(CommonConstants.Bill_TABLE.tableName, CommonConstants.Bill_TABLE.sqlCreate,
    CommonConstants.Bill_TABLE.columns);

  constructor(callback: Function = () => {
  }) {
    this.accountTable.getRdbStore(callback);
  }

  getRdbStore(callback: Function = () => {
  }) {
    this.accountTable.getRdbStore(callback);
  }

  insertData(account: BillItem, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(account);
    this.accountTable.insertData(valueBucket, callback);
  }

  deleteData(account: BillItem, callback: Function) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.Bill_TABLE.tableName);
    predicates.equalTo('id', account.id);
    this.accountTable.deleteData(predicates, callback);
  }

  updateData(account: BillItem, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(account);
    let predicates = new relationalStore.RdbPredicates(CommonConstants.Bill_TABLE.tableName);
    predicates.equalTo('id', account.id);
    this.accountTable.updateData(predicates, valueBucket, callback);
  }
  query(amount: number, callback: Function, isAll: boolean = true) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.Bill_TABLE.tableName);
    if (!isAll) {
      predicates.equalTo('amount', amount);
    }
    this.accountTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      if (count === 0 || typeof count === 'string') {
        console.log(`${CommonConstants.TABLE_TAG}` + 'Query no results!');
        callback([]);
      } else {
        resultSet.goToFirstRow();
        const result: BillItem[] = [];
        for (let i = 0; i < count; i++) {
          let tmp: BillItem = {
            id:-1,
            remark:'',
            title:'',
            time:'',
            amount:0,
            method:'',
            accountType: 0
          }; // 创建一个新的 BillItem 对象，并设置默认值
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));         // 获取 id
          tmp.remark = resultSet.getString(resultSet.getColumnIndex('remark'));     // 获取 icon
          tmp.title = resultSet.getString(resultSet.getColumnIndex('title'));   // 获取 title
          tmp.time = resultSet.getString(resultSet.getColumnIndex('time'));     // 获取 time
          tmp.amount = resultSet.getDouble(resultSet.getColumnIndex('amount')); // 获取 amount
          tmp.method = resultSet.getString(resultSet.getColumnIndex('method')); // 获取 method
          tmp.accountType = resultSet.getDouble(resultSet.getColumnIndex('accountType')); // 获取 accountType
          result[i] = tmp; // 将该 BillItem 对象存入 result 数组
          resultSet.goToNextRow(); // 移动到下一行
        }

        callback(result);
      }
    });
  }
}

function generateBucket(account: BillItem): relationalStore.ValuesBucket {

  let obj: relationalStore.ValuesBucket = {};
  obj.remark = account.remark;           // 添加 remark
  obj.title = account.title;         // 添加 title
  obj.time = account.time;           // 添加 time
  obj.amount = account.amount;       // 添加 amount
  obj.method = account.method;       // 添加 method
  obj.accountType = account.accountType;       // 添加 accountType

  return obj;
}
