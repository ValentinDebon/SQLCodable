/*
	SQLiteError.swift
	Copyright (c) 2020, Valentin Debon
	This file is part of SQLiteCodable
	subject the BSD 3-Clause License, see LICENSE
*/

import CSQLite

/**
	Enumeration of every SQLite error.

	- Note: The list should be exhaustive for sqlite `3.32.3`. Be careful for next releases.
*/
public enum SQLiteError : Int32, Error {
	case ok = 0

	// Beginning of Error codes
	case error      =   1
	case `internal` =   2
	case perm       =   3
	case abort      =   4
	case busy       =   5
	case locked     =   6
	case nomem      =   7
	case readonly   =   8
	case interrupt  =   9
	case ioerr      =  10
	case corrupt    =  11
	case notfound   =  12
	case full       =  13
	case cantopen   =  14
	case `protocol` =  15
	case empty      =  16
	case schema     =  17
	case toobig     =  18
	case constraint =  19
	case mismatch   =  20
	case misuse     =  21
	case nolfs      =  22
	case auth       =  23
	case format     =  24
	case range      =  25
	case notadb     =  26
	case notice     =  27
	case warning    =  28
	case row        = 100
	case done       = 101

	// Extended Error codes
	case errorMissingCollseq    = 257
	case errorRetry             = 513
	case errorSnapshot          = 769
	case ioerrRead              = 266
	case ioerrShortRead         = 522
	case ioerrWrite             = 778
	case ioerrFsync             = 1034
	case ioerrDirFsync          = 1290
	case ioerrTruncate          = 1546
	case ioerrFstat             = 1802
	case ioerrUnlock            = 2058
	case ioerrRdlock            = 2314
	case ioerrDelete            = 2570
	case ioerrBlocked           = 2826
	case ioerrNomem             = 3082
	case ioerrAccess            = 3338
	case ioerrCheckreservedlock = 3594
	case ioerrLock              = 3850
	case ioerrClose             = 4106
	case ioerrDirClose          = 4362
	case ioerrShmopen           = 4618
	case ioerrShmsize           = 4874
	case ioerrShmlock           = 5130
	case ioerrShmmap            = 5386
	case ioerrSeek              = 5642
	case ioerrDeleteNoent       = 5898
	case ioerrMmap              = 6154
	case ioerrGettemppath       = 6410
	case ioerrConvpath          = 6666
	case ioerrVnode             = 6922
	case ioerrAuth              = 7178
	case ioerrBeginAtomic       = 7434
	case ioerrCommitAtomic      = 7690
	case ioerrRollbackAtomic    = 7946
	case lockedSharedcache      = 262
	case lockedVtab             = 518
	case busyRecovery           = 261
	case busySnapshot           = 517
	case cantopenNotempdir      = 270
	case cantopenIsdir          = 526
	case cantopenFullpath       = 782
	case cantopenConvpath       = 1038
	case cantopenDirtywal       = 1294
	case corruptVtab            = 267
	case corruptSequence        = 523
	case readonlyRecovery       = 264
	case readonlyCantlock       = 520
	case readonlyRollback       = 776
	case readonlyDbmoved        = 1032
	case readonlyCantinit       = 1288
	case readonlyDirectory      = 1544
	case abortRollback          = 516
	case constraintCheck        = 275
	case constraintCommithook   = 531
	case constraintForeignkey   = 787
	case constraintFunction     = 1043
	case constraintNotnull      = 1299
	case constraintPrimarykey   = 1555
	case constraintTrigger      = 1811
	case constraintUnique       = 2067
	case constraintVtab         = 2323
	case constraintRowid        = 2579
	case noticeRecoverWal       = 283
	case noticeRecoverRollback  = 539
	case warningAutoindex       = 284
	case authUser               = 279
	case okLoadPermanently      = 256

	public var localizedDescription: String {
		String(cString: sqlite3_errstr(self.rawValue))
	}
}

