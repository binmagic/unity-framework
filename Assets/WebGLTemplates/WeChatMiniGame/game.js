/**
 * 微信小游戏入口文件
 * 负责初始化微信适配器并加载 Unity WebGL 构建
 */

// 导入微信小游戏 Unity 适配器
// 需要将微信小游戏适配插件的 unity-namespace.js 放在同级目录
require('./unity-namespace.js');

// 加载 Unity WebGL 构建
const GameGlobal = require('./{{{ PRODUCT_NAME }}}.js');

// 初始化 Unity 实例
GameGlobal.instantiateWasm = function(imports, successCallback) {
  // WebAssembly 实例化由 Unity 引擎处理
};

// 错误处理
GameGlobal.onRuntimeInitialized = function() {
  console.log('[GameJS] Unity runtime initialized');
};

// 启动
console.log('[GameJS] Starting WeChat Mini Game...');
