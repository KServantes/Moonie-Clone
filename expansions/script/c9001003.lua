--Icearitualia Prismaria
local m=9001003
local cm=_G["c"..m]
function cm.initial_effect(c)

    c:EnableReviveLimit()
    aux.EnablePendulumAttribute(c)
    --Extra Deck Ritual Summon itself
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetDescription(aux.Stringid(m,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCountLimit(1,m-4)
    e1:SetCondition(cm.reccon)
    e1:SetTarget(cm.target)
    e1:SetOperation(cm.activate)
    c:RegisterEffect(e1)
    --Destroy to place one from deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(m,1))
    e2:SetCategory(CATEGORY_TOEXTRA)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1,m-5)
    e2:SetTarget(cm.sctg)
    e2:SetOperation(cm.scop)
    c:RegisterEffect(e2)
    --Shuffle 3 draw 1
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(m,2))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetTarget(cm.target1)
    e3:SetOperation(cm.operation1)
    c:RegisterEffect(e3)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        local mg=Duel.GetRitualMaterial(tp):Filter(cm.matfilter,c,c)
        if c.mat_filter then
            mg=mg:Filter(c.mat_filter,nil)
        end
        if not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) then return end
        if ft>0 then
            return mg:CheckWithSumGreater(Card.GetRitualLevel,c:GetLevel(),c)
        else
            return mg:IsExists(cm.mfilterf,1,nil,tp,mg,c)
        end
    end 
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cm.reccon(e,tp,eg,ep,ev,re,r,rp)
return Duel.GetTurnPlayer()==tp
end

function cm.activate(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local c=e:GetHandler()
    local mg=Duel.GetRitualMaterial(tp):Filter(cm.matfilter,c,c)
    if c.mat_filter then
        mg=mg:Filter(c.mat_filter,nil)
    end
    local mat=nil
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    if ft>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,c:GetLevel(),c)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        mat=mg:FilterSelect(tp,cm.mfilterf,1,1,nil,tp,mg,c)
        Duel.SetSelectedCard(mat)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        local mat2=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,c:GetLevel(),c)
        mat:Merge(mat2)
    end
    c:SetMaterial(mat)
    Duel.ReleaseRitualMaterial(mat)
    Duel.BreakEffect()
    Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)
    c:CompleteProcedure()
end

--Add "Ritualia" Monster from Extra Deck to deck.
function cm.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.scfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function cm.scop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(900100,1))
    local g=Duel.SelectMatchingCard(tp,cm.scfilter,tp,LOCATION_DECK,0,1,1,nil,c)
    local tc=g:GetFirst()
    if tc and Duel.SendtoExtraP(tc,tp,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        Duel.Destroy(c,REASON_EFFECT)
    end
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_EXTRA) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cm.filter1(chkc) end
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(cm.filter1,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,cm.filter1,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
    Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
    local g=Duel.GetOperatedGroup()
    if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
    local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
    if ct==3 then
    Duel.BreakEffect()
    Duel.Draw(tp,1,REASON_EFFECT)
end
end
--Filters
--Is the summon of itself a ritual summon i think? Not a f***ing clue
function cm.remcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
--Honestly the same, no clue what this does, all strange ritual stuff mumbo jumbo
function cm.mfilterf(c,tp,mg,rc)
    if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
        Duel.SetSelectedCard(c)
        return mg:CheckWithSumGreater(Card.GetRitualLevel,rc:GetLevel(),rc)
    else return false end
end
--Are the Mats able to be Tributed for a Ritual Summon 
function cm.matfilter(c,rc)
   return c:IsCanBeRitualMaterial(rc) and c:IsType(TYPE_MONSTER)
end
--Is it a "Ritualia" Monster and can you add it to hand?
function cm.thfilter(c)
    return c:IsSetCard(0x1f5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
--Is it a "Ritualia" Pendulum Monster
function cm.scfilter(c,pc)
    return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x1f5)
end
--Is it a "Ritualia" card that's face-up
function cm.filter1(c)
    return c:IsAbleToDeck() and c:IsSetCard(0x1f5) 
end