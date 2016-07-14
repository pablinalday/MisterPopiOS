//
//  Copyright (c) 2016 Harriague & Asoc. All rights reserved.
//
//  This program is confidential and proprietary to Harriague & Asoc,
//  and may not be copied, reproduced, modified, disclosed to others, published
//  or used, in whole or in part, without the express prior written permission
//  of Harriague & Asoc.
//

#ifndef common_h
#define common_h


////////////////////////////////////////////////////////////////////////////////
// COLORS
////////////////////////////////////////////////////////////////////////////////

/**
 * Create a UIColor from hex string.
 */
#define HEXCOLORA(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 \
green:((c>>8)&0xFF)/255.0 \
blue:((c>>0)&0xFF)/255.0 \
alpha:((c>>24)&0xFF)/255.0]


////////////////////////////////////////////////////////////////////////////////
// MEMORY
////////////////////////////////////////////////////////////////////////////////

/**
 * Safe release.
 * @param obj [in] object to be released.
 */
#define RELEASE_SAFE(obj) { if(obj != nil) { [obj release]; obj = nil; } }


#endif /* common_h */
