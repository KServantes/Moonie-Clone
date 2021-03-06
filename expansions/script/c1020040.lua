--Bushido Toad
--Script by XGlitchy30
function c1020040.initial_effect(c)
	--untargetable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c1020040.untargetable)
	c:RegisterEffect(e1)
	--secure bushido summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1020040,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,1020040)
	e2:SetOperation(c1020040.effect)
	c:RegisterEffect(e2)
	--recycle
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_RECOVER)
	e3:SetDescription(aux.Stringid(1020040,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,1020040)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c1020040.thtg)
	e3:SetOperation(c1020040.thop)
	c:RegisterEffect(e3)
end
--filters
function c1020040.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x4b0) and c:IsAbleToHand()
end
function c1020040.sumcheck(c)
	return c:IsSetCard(0x4b0)
end
--values
function c1020040.untargetable(e,re,rp)
	return rp~=e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
--secure bushido summon
function c1020040.effect(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCode(EVENT_SUMMON_SUCCESS)
	e11:SetCondition(c1020040.uchcon)
	e11:SetOperation(c1020040.unchainable)
	e11:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e11)
	local e21=Effect.CreateEffect(c)
	e21:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e21:SetRange(LOCATION_MZONE)
	e21:SetCode(EVENT_CHAIN_END)
	e21:SetOperation(c1020040.cedop)
	e21:SetLabelObject(e11)
	e21:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e21)
end
function c1020040.chainlm(e,rp,tp)
	return tp==rp
end
function c1020040.uchcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1020040.sumcheck,1,nil)
end
function c1020040.unchainable(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 then
		Duel.SetChainLimitTillChainEnd(c1020040.chainlm)
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(1020040,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,1)
	end
end
function c1020040.cedop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(1020040)~=0 then
		Duel.SetChainLimitTillChainEnd(c1020040.chainlm)
	end
	e:GetHandler():ResetFlagEffect(1020040)
end
--recycle
function c1020040.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c1020040.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c1020040.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,c1020040.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	local lp=g:GetFirst():GetLevel()*300
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,lp)
end
function c1020040.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		local lp=tc:GetLevel()*300
		Duel.Recover(tp,lp,REASON_EFFECT)
	end
end