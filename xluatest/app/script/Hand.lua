

local EVENT = {
    CHUPAI_COMPLETED = 0,
    DIUSHAIZI_COMPLETED = 1,
    NAPAI_COMPLETED = 2,
    FANGPAI_COMPLETED = 3,
    HUPAI_COMPLETED = 4,
    PENGGANG_COMPLETED = 5,
end

-- @param type : Animator
local _animator
local _callback = {}

local _M = {}

_M.EVENT = EVENT

function _M:Start() 
    _animator = self.gameObject:GetComponent<Animator>();
end

function _M:Update() 
    if _animator ~= nil then
        AnimatorStateInfo si = _animator.GetCurrentAnimatorStateInfo(0);
        if si.IsName("Base Layer.Chupai") then
            _animator.SetBool("Chupai", false);
        elseif si.IsName("Base Layer.Chutuipai") then
            _animator.SetBool("Chutuipai", false);
        elseif si.IsName("Base Layer.Diushaizi") then
            _animator.SetBool("Diushaizi", false);
        elseif si.IsName("Base Layer.Hupai") then
            _animator.SetBool("Hupai", false);
        elseif si.IsName("Base Layer.Napai") then
            _animator.SetBool("Napai", false);
        elseif si.IsName("Base Layer.Fangpai") then
            _animator.SetBool("Fangpai", false);
        elseif si.IsName("Base Layer.Penggang") then
            _animator.SetBool("Penggang", false);
        elseif si.IsName("Base Layer.Idle") then
            _animator.SetBool("Idle", false);
        end
    end
end

function _M:Rigster(name, cb)
    _callback.Add(name, cb);
end

function _M:OnChupaiCompleted()
    if _callback[EVENT.CHUPAI_COMPLETED) then
        var cb = _callback[EVENT.CHUPAI_COMPLETED];
        cb();
    end
end

function _M:OnDiushaiziCompleted()
    if _callback[EVENT.DIUSHAIZI_COMPLETED) then
        var cb = _callback[EVENT.DIUSHAIZI_COMPLETED];
        cb();
    end
end

function _M:OnNapaiCompleted()
    if _callback[EVENT.NAPAI_COMPLETED) then
        var cb = _callback[EVENT.NAPAI_COMPLETED];
        cb();
    end
end

function _M:OnFangpaiCompleted()
    if _callback[EVENT.FANGPAI_COMPLETED] then
        var cb = _callback[EVENT.FANGPAI_COMPLETED];
        cb();
    end
end

function _M:OnHupaiCompleted()
    if _callback[EVENT.HUPAI_COMPLETED] then
        var cb = _callback[EVENT.HUPAI_COMPLETED];
        cb();
    end
end

function _M:OnPengGangCompleted()
    if _callback[EVENT.PENGGANG_COMPLETED] then
        var cb = _callback[EVENT.PENGGANG_COMPLETED];
        cb();
    end
end

return _M