﻿// -------------------------------------------------------------------------
//    @FileName			:    NFIStateMachine.h
//    @Author           :    LvSheng.Huang
//    @Date             :    2017-02-08
//    @Module           :    NFIStateMachine
//    @Desc             :
// -------------------------------------------------------------------------

#ifndef NFI_STATE_MACHINE_H
#define NFI_STATE_MACHINE_H

#include "NFIState.h"

class NFIStateMachine
	: public NFIModule
{
public:

    virtual const NFAI_STATE  CurrentState() const = 0;
	virtual const NFAI_STATE  LastState() const = 0;

	virtual NFIState* GetState(const NFAI_STATE eState) const = 0;

    //change to a new state
    virtual void ChangeState(const NFAI_STATE eState) = 0;

    //return last state
    virtual void RevertToLastState() = 0;

protected:

private:
};

#endif