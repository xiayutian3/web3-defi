// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "hardhat/console.sol";
import "./Context.sol";

// 已部署在 goerli测试网中  地址： 0x36d072a4926f181D8f034d7aAA7C9498fc948886
// ERC20 合约

contract MyToken is Context {
    // 5.事件、
    // 转账事件
    event Transfer(address from, address to, uint256 amount);
    // 审批事件（额度）
    event Approval(address owner, address spender, uint256 amount);


    // 1.代币信息
    // 代币名称 name
    string private _name;
    // 代币标识 symbol
    string private _symbol;
    // 代币小数位数 decimals
    uint8 private _decimals;
    // 代币总发行量 totalSupply
    uint256 private _totalSupply;
    // 代币数量（某个账户）balance
    mapping(address => uint256) private _balances;
    // 授权代币数量 allowance
    mapping(address => mapping(address => uint256)) private _allowances;

    // 2.初始化
    constructor(){
        _name = "RabbitCoin";
        _symbol = "RABTC";
        _decimals = 18;

        // 初始化货币池
        _mint(_msgSender(), 100*10000*10**_decimals);
    }

    // 3.取值器
    function name() public view returns (string memory){
        return _name;
    }
    function symbol() public view returns (string memory){
        return _symbol;
    }
    function decimals() public view returns (uint8){
        return _decimals;
    }
    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }
    function balanceOf(address _owner) public view returns (uint256 balance){
        return _balances[_owner];
    }
    // 返回授权的代币数量
    function allowance(address _owner, address _spender) public view returns (uint256 ){
        return _allowances[_owner][_spender];
    }

    // 4.函数
    // 转发代币
    function transfer(address to, uint256 amount) public returns (bool){
        address owner = _msgSender();
        // console.log("owner:",owner);
        // 实现转账
        _transfer(owner, to, amount);
        return true;
    }
    // 代币授权的转发
    function approve(address spender, uint256 amount) public returns(bool){
        // 银行授权给我 （银行转账给我）
        address owner = _msgSender();
        // owner 是授权人
        // spender 被授权人
        _approve(owner, spender, amount);
        return true;
    }
    // 授权代币转发(提款到自己的账户，msg.sender是调用者 我。银行借钱给我，我要提款到自己的账户)
    function transferFrom(address from, address to, uint256 amount) public returns (bool){
        address owner = _msgSender(); //我
        // 更改授权账户信息
        // from 银行
        // owner 我
        _spendAllowance(from, owner, amount);

        //执行转账
        // from：银行
        // to： 可能是 我自己，中介公司，卖房人
        _transfer(from, to, amount);
        return true;
    }

    // 自毁合约，如果有余额，强制发送剩余主币 给 msg.sender， msg.sender默认没有payable属性
    function kill() external {
        selfdestruct(payable(msg.sender));
    }





    // 6.合约内部函数
    // 铸币函数
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        // 初始化货币数量
        _totalSupply += amount;
        // 给某个账号注入起始资金
        unchecked { //不进行检查，因为已经做了地址判断，不会出问题了
            _balances[account] += amount;
        }
        
    }


    // 转账函数
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, unicode"ERC20: 余额不足");
        unchecked { //这一步不做检检查了，上面已经做了很多的条件判断
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        //触发转账成功事件
        emit Transfer(from, to, amount);

    }

    // 授权操作
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: transfer from the zero address");
        require(spender != address(0), "ERC20: transfer to the zero address");
        // 执行授权
        _allowances[owner][spender] = amount;
        // 触发审批成功事件
        emit Approval(owner, spender, amount);
    }

    // 修改授权额度信息
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner,spender);
        if(currentAllowance != type(uint256).max){ //判断是否超过最大值
            require(currentAllowance >= amount, unicode"ERC20: 余额不足");
            unchecked {
                _approve(owner,spender,currentAllowance-amount);
            }
        }
    }


    /*
        event Transfer(address indexed _from, address indexed _to, uint256 _value)
        event Approval(address indexed _owner, address indexed _spender, uint256 _value)

        function name() public view returns (string)
        function symbol() public view returns (string)
        function decimals() public view returns (uint8)
        function totalSupply() public view returns (uint256)
        function balanceOf(address _owner) public view returns (uint256 balance)
        function transfer(address _to, uint256 _value) public returns (bool success)
        function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
        function approve(address _spender, uint256 _value) public returns (bool success)
        function allowance(address _owner, address _spender) public view returns (uint256 remaining)
    */

    /*
        approve 审批  tansferFrom 转账（第三方转账）
        主体：借款人， 贷款人，中介公司，房屋出售者 account
        授权：贷款人（银行）借钱给我 approve 100w
        提款：从银行贷款账户里提钱给自己 tansferFrom 1w
        支付房款：借款人转账给房屋出售者 tansferFrom 90w
        支付佣金：借款人转账中介公司 tansferFrom 9w
    
    */
}