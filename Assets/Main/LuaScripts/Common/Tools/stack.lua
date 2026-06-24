
--在 Lua 中实现一个简单的栈（Stack）类，可以利用表（table）来实现。
-- 栈是一种数据结构，遵循后进先出（LIFO，Last In, First Out）的原则，即最新压入栈的元素最先弹出。

-- Stack类的实现
local Stack = {}
Stack.__index = Stack

-- 创建一个新的栈实例
function Stack.new()
	local instance = {
		items = {}  -- 栈的数据存储
	}
	setmetatable(instance, Stack)
	return instance
end

-- 压入栈
function Stack:push(item)
	table.insert(self.items, item)
end

-- 弹出栈
function Stack:pop()
	if #self.items == 0 then
		error("Stack is empty")
		return nil
	end
	return table.remove(self.items)
end

-- 查看栈顶元素
function Stack:peek()
	if #self.items == 0 then
		error("Stack is empty")
		return nil
	end
	return self.items[#self.items]
end

-- 检查栈是否为空
function Stack:is_empty()
	return #self.items == 0
end

-- 获取栈的大小
function Stack:size()
	return #self.items
end

-- 清空栈
function Stack:clear()
	self.items = {}
end

-- 打印栈内容（调试用途）
function Stack:print_stack()
	for i = #self.items, 1, -1 do
		print(self.items[i])
	end
end

return Stack

---- 使用示例
--local myStack = Stack.new()

---- 压入元素
--myStack:push(10)
--myStack:push(20)
--myStack:push(30)

---- 查看栈顶元素
--print("Top element:", myStack:peek())  -- 输出：Top element: 30

---- 弹出元素
--print("Popped element:", myStack:pop())  -- 输出：Popped element: 30

---- 查看栈大小
--print("Stack size:", myStack:size())  -- 输出：Stack size: 2

---- 打印栈内容
--myStack:print_stack()  -- 输出：20, 10

---- 清空栈
--myStack:clear()

---- 检查栈是否为空
--print("Is stack empty?", myStack:is_empty())  -- 输出：Is stack empty? true
