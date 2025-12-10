import { Test, TestingModule } from '@nestjs/testing';
import { AppointmentsController } from './appointments.controller';
import { AppointmentsService } from './appointments.service';
import { CurrentUserData } from '../auth/strategies/jwt.strategy';

describe('AppointmentsController', () => {
  let controller: AppointmentsController;
  let service: AppointmentsService;

  const mockAppointmentsService = {
    create: jest.fn(),
    findAll: jest.fn(),
    findOne: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
    regenerateInviteUrl: jest.fn(),
  };

  const currentUser: CurrentUserData = {
    userId: 'user-1',
    email: 'test@example.com',
  };

  const mockAppointment = {
    appointmentId: 1,
    createdUserId: 'user-1',
    title: 'テスト予約',
    latitude: '35.6812',
    longitude: '139.7671',
    appointmentDate: '2025-12-15',
    appointmentTime: '14:00:00',
    status: 'active',
    inviteUrl: 'http://localhost:3001/invite/test-token-123',
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AppointmentsController],
      providers: [
        {
          provide: AppointmentsService,
          useValue: mockAppointmentsService,
        },
      ],
    }).compile();

    controller = module.get<AppointmentsController>(AppointmentsController);
    service = module.get<AppointmentsService>(AppointmentsService);

    jest.clearAllMocks();
  });

  it('コントローラーが定義されているべき', () => {
    expect(controller).toBeDefined();
  });

  describe('create', () => {
    it('予約を作成する', async () => {
      const createDto = {
        title: 'テスト予約',
        latitude: 35.6812,
        longitude: 139.7671,
        appointmentDate: '2025-12-15',
        appointmentTime: '14:00:00',
      };

      mockAppointmentsService.create.mockResolvedValue(mockAppointment);

      const result = await controller.create(currentUser, createDto);

      expect(mockAppointmentsService.create).toHaveBeenCalledWith(
        currentUser.userId,
        createDto,
      );
      expect(result).toEqual(mockAppointment);
    });
  });

  describe('findAll', () => {
    it('予約一覧を取得する', async () => {
      const appointments = [mockAppointment, { ...mockAppointment, appointmentId: 2 }];
      mockAppointmentsService.findAll.mockResolvedValue(appointments);

      const result = await controller.findAll(currentUser);

      expect(mockAppointmentsService.findAll).toHaveBeenCalledWith(
        currentUser.userId,
      );
      expect(result).toEqual(appointments);
      expect(result).toHaveLength(2);
    });
  });

  describe('findOne', () => {
    it('予約詳細を取得する', async () => {
      mockAppointmentsService.findOne.mockResolvedValue(mockAppointment);

      const result = await controller.findOne(currentUser, 1);

      expect(mockAppointmentsService.findOne).toHaveBeenCalledWith(
        1,
        currentUser.userId,
      );
      expect(result).toEqual(mockAppointment);
    });
  });

  describe('update', () => {
    it('予約を更新する', async () => {
      const updateDto = {
        title: '更新されたタイトル',
      };
      const updatedAppointment = { ...mockAppointment, title: '更新されたタイトル' };
      mockAppointmentsService.update.mockResolvedValue(updatedAppointment);

      const result = await controller.update(currentUser, 1, updateDto);

      expect(mockAppointmentsService.update).toHaveBeenCalledWith(
        1,
        currentUser.userId,
        updateDto,
      );
      expect(result.title).toBe('更新されたタイトル');
    });
  });

  describe('remove', () => {
    it('予約を削除する', async () => {
      mockAppointmentsService.remove.mockResolvedValue({
        message: 'Appointment cancelled successfully',
      });

      const result = await controller.remove(currentUser, 1);

      expect(mockAppointmentsService.remove).toHaveBeenCalledWith(
        1,
        currentUser.userId,
      );
      expect(result.message).toBe('Appointment cancelled successfully');
    });
  });

  describe('regenerateUrl', () => {
    it('招待URLを再生成する', async () => {
      const updatedAppointment = {
        ...mockAppointment,
        inviteUrl: 'http://localhost:3001/invite/new-token-456',
      };
      mockAppointmentsService.regenerateInviteUrl.mockResolvedValue(
        updatedAppointment,
      );

      const result = await controller.regenerateUrl(currentUser, 1);

      expect(mockAppointmentsService.regenerateInviteUrl).toHaveBeenCalledWith(
        1,
        currentUser.userId,
      );
      expect(result.inviteUrl).toContain('new-token-456');
    });
  });
});
