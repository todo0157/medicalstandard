export interface UserProfile {
  id: string;
  name: string;
  age: number;
  gender: 'male' | 'female';
  address: string;
  profileImageUrl?: string;
  phoneNumber?: string;
  appointmentCount: number;
  treatmentCount: number;
  isPractitioner: boolean;
  certificationStatus: 'none' | 'pending' | 'verified';
  licenseNumber?: string;
  clinicName?: string;
  createdAt: string;
  updatedAt: string;
}
