--Vulpine Guard
function c249000126.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5818294,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(c249000126.negcon)
	e1:SetCost(c249000126.negcost)
	e1:SetTarget(c249000126.negtg)
	e1:SetOperation(c249000126.negop)
	c:RegisterEffect(e1)
end
function c249000126.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_BEAST)
end
function c249000126.confilter(c)
	return c:IsRace(RACE_BEAST) and not c:IsCode(249000126)
end
function c249000126.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c249000126.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev) and Duel.IsExistingMatchingCard(c249000126.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
function c249000126.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c249000126.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function c249000126.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end