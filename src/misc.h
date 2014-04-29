#ifndef __MISC_H
#define __MISC_H


Obj FuncPermLeftQuoTransformationNC(Obj self, Obj t1, Obj t2);
Obj FuncMappingPermSetSet(Obj self, Obj src, Obj dst);
Obj FuncMappingPermListList(Obj self, Obj src, Obj dst);

#if 0
Obj FuncImageAndKernelOfTransformation2( Obj self, Obj t );
#endif

Obj FuncImageAndKernelOfTransformation( Obj self, Obj t );
Obj FuncTABLE_OF_TRANS_KERNEL( Obj self, Obj k, Obj n );
Obj FuncCANONICAL_TRANS_SAME_KERNEL( Obj self, Obj t );
Obj FuncIS_INJECTIVE_TRANS_ON_LIST( Obj self, Obj t, Obj l );
  
#endif

/*
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; version 2 of the License.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */


