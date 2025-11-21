-- CreateTable
CREATE TABLE "UserProfile" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "age" INTEGER NOT NULL,
    "gender" TEXT NOT NULL DEFAULT 'male',
    "address" TEXT NOT NULL,
    "profileImageUrl" TEXT,
    "phoneNumber" TEXT,
    "appointmentCount" INTEGER NOT NULL DEFAULT 0,
    "treatmentCount" INTEGER NOT NULL DEFAULT 0,
    "isPractitioner" BOOLEAN NOT NULL DEFAULT false,
    "certificationStatus" TEXT NOT NULL DEFAULT 'none',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
